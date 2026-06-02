import SwiftUI

struct PhoneRootView: View {
    @EnvironmentObject private var metricsStore: SelectedMetricsStore
    @EnvironmentObject private var phoneSession: PhoneSessionCoordinator

    var body: some View {
        TabView {
            PhoneStatsView()
                .tabItem {
                    Label("Stats", systemImage: "heart.text.square")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
        }
        .tint(.green)
    }
}

private struct PhoneStatsView: View {
    @EnvironmentObject private var metricsStore: SelectedMetricsStore
    @EnvironmentObject private var phoneSession: PhoneSessionCoordinator

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.black, Color(red: 0.02, green: 0.12, blue: 0.08)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                StatsGridView(readings: phoneSession.snapshot.visibleReadings(selectedMetrics: metricsStore.selectedMetrics))
                    .padding()
            }
            .navigationTitle("SimplyVitals")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

private struct SettingsView: View {
    @EnvironmentObject private var metricsStore: SelectedMetricsStore

    var body: some View {
        NavigationStack {
            List {
                Section("Shown Stats") {
                    ForEach(VitalMetric.allCases) { metric in
                        Toggle(metric.title, isOn: binding(for: metric))
                    }
                }

                Section("Suggestions") {
                    Text("Respiratory rate, HRV, active energy, and wrist temperature can add useful exercise context without turning the app into a timer-heavy workout dashboard.")
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func binding(for metric: VitalMetric) -> Binding<Bool> {
        Binding(
            get: { metricsStore.selectedMetrics.contains(metric) },
            set: { metricsStore.toggle(metric, isOn: $0) }
        )
    }
}
