import Foundation
import WatchConnectivity

@MainActor
final class PhoneSessionCoordinator: NSObject, ObservableObject {
    @Published private(set) var snapshot = VitalsSnapshot.empty

    private weak var metricsStore: SelectedMetricsStore?
    private var isStarted = false

    func start(metricsStore: SelectedMetricsStore) {
        guard WCSession.isSupported(), !isStarted else { return }
        isStarted = true
        self.metricsStore = metricsStore

        metricsStore.setOnChange { [weak self] selectedMetrics in
            self?.sendSelectedMetrics(selectedMetrics)
        }

        WCSession.default.delegate = self
        WCSession.default.activate()
        sendSelectedMetrics(metricsStore.selectedMetrics)
    }

    private func sendSelectedMetrics(_ metrics: Set<VitalMetric>) {
        let ids = metrics.map(\.rawValue)
        let payload: [String: Any] = ["selectedMetricIDs": ids]

        if WCSession.default.isReachable {
            WCSession.default.sendMessage(payload, replyHandler: nil)
        }
    }
}

extension PhoneSessionCoordinator: WCSessionDelegate {
    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handle(message)
    }

    private nonisolated func handle(_ payload: [String: Any]) {
        guard
            let data = payload["snapshot"] as? Data,
            let snapshot = try? JSONDecoder().decode(VitalsSnapshot.self, from: data)
        else { return }

        Task { @MainActor in
            self.snapshot = snapshot
        }
    }
}
