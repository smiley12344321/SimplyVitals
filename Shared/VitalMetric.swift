import Foundation
import HealthKit

enum VitalMetric: String, CaseIterable, Identifiable, Codable {
    case heartRate
    case bloodOxygen
    case activeEnergy
    case respiratoryRate
    case heartRateVariability
    case wristTemperature

    var id: String { rawValue }

    var title: String {
        switch self {
        case .heartRate: "Heart Rate"
        case .bloodOxygen: "Blood Oxygen"
        case .activeEnergy: "Active Energy"
        case .respiratoryRate: "Respiratory Rate"
        case .heartRateVariability: "HRV"
        case .wristTemperature: "Wrist Temp"
        }
    }

    var shortTitle: String {
        switch self {
        case .heartRate: "HR"
        case .bloodOxygen: "SpO2"
        case .activeEnergy: "Energy"
        case .respiratoryRate: "Resp"
        case .heartRateVariability: "HRV"
        case .wristTemperature: "Temp"
        }
    }

    var unitLabel: String {
        switch self {
        case .heartRate: "bpm"
        case .bloodOxygen: "%"
        case .activeEnergy: "kcal"
        case .respiratoryRate: "br/min"
        case .heartRateVariability: "ms"
        case .wristTemperature: "degF"
        }
    }

    var quantityType: HKQuantityType? {
        switch self {
        case .heartRate:
            HKQuantityType.quantityType(forIdentifier: .heartRate)
        case .bloodOxygen:
            HKQuantityType.quantityType(forIdentifier: .oxygenSaturation)
        case .activeEnergy:
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)
        case .respiratoryRate:
            HKQuantityType.quantityType(forIdentifier: .respiratoryRate)
        case .heartRateVariability:
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        case .wristTemperature:
            HKQuantityType.quantityType(forIdentifier: .appleSleepingWristTemperature)
        }
    }

    var healthUnit: HKUnit {
        switch self {
        case .heartRate:
            HKUnit.count().unitDivided(by: .minute())
        case .bloodOxygen:
            .percent()
        case .activeEnergy:
            .kilocalorie()
        case .respiratoryRate:
            HKUnit.count().unitDivided(by: .minute())
        case .heartRateVariability:
            .secondUnit(with: .milli)
        case .wristTemperature:
            .degreeFahrenheit()
        }
    }

    var defaultIsVisible: Bool {
        switch self {
        case .heartRate, .bloodOxygen:
            true
        case .activeEnergy, .respiratoryRate, .heartRateVariability, .wristTemperature:
            false
        }
    }
}
