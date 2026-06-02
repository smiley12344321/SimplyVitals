import Foundation

struct VitalReading: Identifiable, Codable, Equatable {
    var metric: VitalMetric
    var value: Double?
    var measuredAt: Date?

    var id: String { metric.id }

    var displayValue: String {
        guard let value else { return "--" }

        switch metric {
        case .heartRate, .activeEnergy:
            return value.formatted(.number.precision(.fractionLength(0)))
        case .bloodOxygen:
            return (value * 100).formatted(.number.precision(.fractionLength(0)))
        case .respiratoryRate:
            return value.formatted(.number.precision(.fractionLength(1)))
        case .heartRateVariability:
            return value.formatted(.number.precision(.fractionLength(0)))
        case .wristTemperature:
            return value.formatted(.number.precision(.fractionLength(1)))
        }
    }

    var freshnessText: String {
        guard let measuredAt else { return "Waiting" }
        let age = Date().timeIntervalSince(measuredAt)

        if age < 15 {
            return "Live"
        }

        if age < 60 {
            return "\(Int(age))s ago"
        }

        return "\(Int(age / 60))m ago"
    }
}
