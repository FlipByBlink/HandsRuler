import Foundation

enum 🧾ResultFormatter {
    static func string(_ lineLength: Float, _ unit: 📐Unit) -> String {
        if unit == .feetAndInches {
            let measurement = Measurement(value: .init(lineLength),
                                          unit: UnitLength.meters)
            
            let inchValue = Int(measurement.converted(to: .inches).value)
            
            let feetFormatter = NumberFormatter()
            feetFormatter.maximumFractionDigits = 0
            let feetPart = "\(feetFormatter.string(for: inchValue / 12) ?? "-") ft"
            
            let inchFormatter = NumberFormatter()
            inchFormatter.maximumFractionDigits = 0
            inchFormatter.minimumIntegerDigits = 2
            let inchPart = "\(inchFormatter.string(for: inchValue % 12) ?? "--") in"
            
            return ("\(feetPart) \(inchPart)")
        } else {
            let formatter = MeasurementFormatter()
            formatter.unitOptions = .providedUnit
            let fractionDigits: Int = {
                switch unit {
                    case .centiMeters: 0
                    case .inches: 1
                    case .meters, .feet, .yards: 2
                    case .feetAndInches: fatalError()
                }
            }()
            formatter.numberFormatter.minimumFractionDigits = fractionDigits
            formatter.numberFormatter.maximumFractionDigits = fractionDigits
            let measurement = Measurement(value: .init(lineLength),
                                          unit: UnitLength.meters)
            return formatter.string(from: measurement.converted(to: unit.value))
        }
    }
}
