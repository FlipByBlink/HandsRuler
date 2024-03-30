import Foundation

struct 🪧ResultModel {
    var label: String
    var size: Double
    init(_ lineLength: Float, _ unit: 📏Unit) {
        self.label = Self.formatted(lineLength, unit)
        self.size = max(.init(lineLength * 30), 20)
    }
}

extension 🪧ResultModel {
    static let placeholder: Self = .init(0.4, .meters)
}

private extension 🪧ResultModel {
    private static func formatted(_ lineLength: Float, _ unit: 📏Unit) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        var fractionDigits: Int {
            switch unit {
                case .centiMeters, .inches: 1
                case .meters, .feet, .yards: 2
            }
        }
        formatter.numberFormatter.minimumFractionDigits = fractionDigits
        formatter.numberFormatter.maximumFractionDigits = fractionDigits
        let measurement = Measurement(value: .init(lineLength),
                                      unit: UnitLength.meters)
        return formatter.string(from: measurement.converted(to: unit.value))
    }
}
