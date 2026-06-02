import Foundation

struct VitalsSnapshot: Codable, Equatable {
    var readings: [VitalReading]
    var updatedAt: Date

    static let empty = VitalsSnapshot(
        readings: VitalMetric.allCases.map { VitalReading(metric: $0, value: nil, measuredAt: nil) },
        updatedAt: .now
    )

    func visibleReadings(selectedMetrics: Set<VitalMetric>) -> [VitalReading] {
        readings.filter { selectedMetrics.contains($0.metric) }
    }
}
