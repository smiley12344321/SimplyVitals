import SwiftUI

@main
struct SimplyVitalsWatchApp: App {
    @StateObject private var metricsStore = SelectedMetricsStore()
    @StateObject private var vitalsManager = WatchVitalsManager()
    @StateObject private var watchSession = WatchSessionCoordinator()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            WatchStatsView()
                .environmentObject(metricsStore)
                .environmentObject(vitalsManager)
                .task {
                    watchSession.start(metricsStore: metricsStore, vitalsManager: vitalsManager)
                    await vitalsManager.start()
                }
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        Task { await vitalsManager.start() }
                    } else if phase == .background {
                        vitalsManager.stop()
                    }
                }
        }
    }
}
