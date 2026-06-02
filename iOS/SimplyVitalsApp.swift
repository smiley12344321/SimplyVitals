import SwiftUI

@main
struct SimplyVitalsApp: App {
    @StateObject private var metricsStore = SelectedMetricsStore()
    @StateObject private var phoneSession = PhoneSessionCoordinator()

    var body: some Scene {
        WindowGroup {
            PhoneRootView()
                .environmentObject(metricsStore)
                .environmentObject(phoneSession)
                .task {
                    phoneSession.start(metricsStore: metricsStore)
                }
        }
    }
}
