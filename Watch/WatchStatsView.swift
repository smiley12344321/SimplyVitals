import SwiftUI

struct WatchStatsView: View {
    @EnvironmentObject private var metricsStore: SelectedMetricsStore
    @EnvironmentObject private var vitalsManager: WatchVitalsManager

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.green.opacity(0.28), .black], center: .top, startRadius: 8, endRadius: 190)
                .ignoresSafeArea()

            StatsGridView(readings: vitalsManager.snapshot.visibleReadings(selectedMetrics: metricsStore.selectedMetrics))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        }
        .toolbar(.hidden)
    }
}
