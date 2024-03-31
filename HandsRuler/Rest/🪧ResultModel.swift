import Foundation

struct 🪧ResultModel {
    var label: String
    var size: Double
    init(_ lineLength: Float, _ unit: 📐Unit) {
        self.label = Self.formatted(lineLength, unit)
        self.size = max(.init(lineLength * 30), 20)
    }
}

extension 🪧ResultModel {
    static let placeholder: Self = .init(0.4, .meters)
}

private extension 🪧ResultModel {
    private static func formatted(_ lineLength: Float, _ unit: 📐Unit) -> String {
        if unit == .feetAndInches {
            let measurement = Measurement(value: .init(lineLength), unit: UnitLength.meters)
            let feetFormatter = MeasurementFormatter()
            feetFormatter.unitOptions = .providedUnit
            feetFormatter.numberFormatter.maximumFractionDigits = 0
            let inchFormatter = MeasurementFormatter()
            inchFormatter.unitOptions = .providedUnit
            inchFormatter.numberFormatter.maximumFractionDigits = 0
            let feetValue = measurement.converted(to: .feet).value
            let rounded = feetValue.rounded(.towardZero)
            let feetPart = Measurement(value: rounded, unit: UnitLength.feet)
            let inchPart = Measurement(value: feetValue - rounded, unit: UnitLength.feet).converted(to: .inches)
            return ("\(feetFormatter.string(from: feetPart)) \(inchFormatter.string(from: inchPart))")
        } else {
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .providedUnit
            var fractionDigits: Int {
                switch unit {
                    case .centiMeters, .inches: 1
                    case .meters, .feet, .yards: 2
                    case .feetAndInches: fatalError()
                }
            }
            formatter.numberFormatter.minimumFractionDigits = fractionDigits
            formatter.numberFormatter.maximumFractionDigits = fractionDigits
            let measurement = Measurement(value: .init(lineLength),
                                          unit: UnitLength.meters)
            return formatter.string(from: measurement.converted(to: unit.value))
        }
    }
}
