import Foundation
import HealthKit

@MainActor
final class WatchVitalsManager: NSObject, ObservableObject {
    @Published private(set) var snapshot = VitalsSnapshot.empty

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var foregroundQueries: [HKQuery] = []
    private var stopTask: Task<Void, Never>?
    private var readings = Dictionary(uniqueKeysWithValues: VitalsSnapshot.empty.readings.map { ($0.metric, $0) })

    func start() async {
        guard HKHealthStore.isHealthDataAvailable(), session == nil else { return }

        do {
            try await requestAuthorization()
            try startWorkoutSession()
            startLatestSampleQueries()
            scheduleOneHourStop()
        } catch {
            print("Unable to start vitals session: \(error.localizedDescription)")
        }
    }

    func stop() {
        foregroundQueries.forEach(healthStore.stop)
        foregroundQueries.removeAll()
        builder?.endCollection(withEnd: .now) { _, _ in }
        session?.end()
        session = nil
        builder = nil
        stopTask?.cancel()
        stopTask = nil
    }

    private func requestAuthorization() async throws {
        let readTypes = Set(VitalMetric.allCases.compactMap(\.quantityType))
        let writeTypes: Set<HKSampleType> = [HKObjectType.workoutType()]

        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
    }

    private func startWorkoutSession() throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .unknown

        let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        let builder = session.associatedWorkoutBuilder()

        builder.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        builder.delegate = self
        session.delegate = self

        self.session = session
        self.builder = builder

        session.startActivity(with: .now)
        builder.beginCollection(withStart: .now) { _, _ in }
    }

    private func startLatestSampleQueries() {
        for metric in VitalMetric.allCases where metric != .heartRate && metric != .activeEnergy {
            guard let type = metric.quantityType else { continue }

            let query = HKAnchoredObjectQuery(
                type: type,
                predicate: nil,
                anchor: nil,
                limit: HKObjectQueryNoLimit
            ) { [weak self] _, samples, _, _, _ in
                self?.consume(samples, for: metric)
            }

            query.updateHandler = { [weak self] _, samples, _, _, _ in
                self?.consume(samples, for: metric)
            }

            foregroundQueries.append(query)
            healthStore.execute(query)
        }
    }

    private nonisolated func consume(_ samples: [HKSample]?, for metric: VitalMetric) {
        guard
            let sample = samples?
                .compactMap({ $0 as? HKQuantitySample })
                .max(by: { $0.endDate < $1.endDate })
        else { return }

        Task { @MainActor in
            update(metric, value: sample.quantity.doubleValue(for: metric.healthUnit), measuredAt: sample.endDate)
        }
    }

    private func scheduleOneHourStop() {
        stopTask?.cancel()
        stopTask = Task { [weak self] in
            try? await Task.sleep(for: .hours(1))
            await MainActor.run {
                self?.stop()
            }
        }
    }

    private func update(_ metric: VitalMetric, value: Double, measuredAt: Date = .now) {
        readings[metric] = VitalReading(metric: metric, value: value, measuredAt: measuredAt)
        snapshot = VitalsSnapshot(readings: VitalMetric.allCases.compactMap { readings[$0] }, updatedAt: .now)
    }
}

extension WatchVitalsManager: HKLiveWorkoutBuilderDelegate {
    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}

    nonisolated func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        Task { @MainActor in
            for sampleType in collectedTypes {
                guard let quantityType = sampleType as? HKQuantityType else { continue }

                if quantityType == VitalMetric.heartRate.quantityType,
                   let statistics = workoutBuilder.statistics(for: quantityType) {
                    update(.heartRate, value: statistics.mostRecentQuantity()?.doubleValue(for: VitalMetric.heartRate.healthUnit) ?? 0)
                }

                if quantityType == VitalMetric.activeEnergy.quantityType,
                   let statistics = workoutBuilder.statistics(for: quantityType) {
                    update(.activeEnergy, value: statistics.sumQuantity()?.doubleValue(for: VitalMetric.activeEnergy.healthUnit) ?? 0)
                }
            }
        }
    }
}

extension WatchVitalsManager: HKWorkoutSessionDelegate {
    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {}

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        Task { @MainActor in
            print("Workout session failed: \(error.localizedDescription)")
            stop()
        }
    }
}
