import Combine
import Foundation
import WatchConnectivity

@MainActor
final class WatchSessionCoordinator: NSObject, ObservableObject {
    private weak var metricsStore: SelectedMetricsStore?
    private weak var vitalsManager: WatchVitalsManager?
    private var cancellable: AnyCancellable?
    private var isStarted = false

    func start(metricsStore: SelectedMetricsStore, vitalsManager: WatchVitalsManager) {
        guard WCSession.isSupported(), !isStarted else { return }
        isStarted = true
        self.metricsStore = metricsStore
        self.vitalsManager = vitalsManager

        WCSession.default.delegate = self
        WCSession.default.activate()

        cancellable = vitalsManager.$snapshot
            .removeDuplicates()
            .sink { [weak self] snapshot in
                self?.send(snapshot)
            }
    }

    private func send(_ snapshot: VitalsSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        let payload: [String: Any] = ["snapshot": data]

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil)
        }
    }
}

extension WatchSessionCoordinator: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handle(message)
    }

    private nonisolated func handle(_ payload: [String: Any]) {
        guard let ids = payload["selectedMetricIDs"] as? [String] else { return }
        let metrics = Set(ids.compactMap(VitalMetric.init(rawValue:)))

        Task { @MainActor in
            self.metricsStore?.replace(with: metrics)
        }
    }
}
