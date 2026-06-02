import Foundation

@MainActor
final class SelectedMetricsStore: ObservableObject {
    @Published var selectedMetrics: Set<VitalMetric> {
        didSet { persist() }
    }

    private let key = "selectedVitalMetricIDs"
    private let defaults: UserDefaults
    private var onChange: ((Set<VitalMetric>) -> Void)?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let ids = defaults.array(forKey: key) as? [String] {
            let metrics = ids.compactMap(VitalMetric.init(rawValue:))
            selectedMetrics = Set(metrics)
        } else {
            selectedMetrics = Set(VitalMetric.allCases.filter(\.defaultIsVisible))
        }
    }

    func setOnChange(_ handler: @escaping (Set<VitalMetric>) -> Void) {
        onChange = handler
    }

    func toggle(_ metric: VitalMetric, isOn: Bool) {
        if isOn {
            selectedMetrics.insert(metric)
        } else {
            selectedMetrics.remove(metric)
        }
    }

    func replace(with metrics: Set<VitalMetric>) {
        selectedMetrics = metrics
    }

    private func persist() {
        defaults.set(selectedMetrics.map(\.rawValue), forKey: key)
        onChange?(selectedMetrics)
    }
}
