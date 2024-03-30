import Foundation

struct 🪧ResultModel {
    var label: String
    var size: Double
    init(_ lineLength: Float, _ unit: 📏Unit) {
        self.label = Self.formatted(lineLength, unit.value)
        self.size = max(.init(lineLength * 30), 20)
    }
}

extension 🪧ResultModel {
    static let placeholder: Self = .init(0.4, .meters)
}

private extension 🪧ResultModel {
    private static func formatted(_ lineLength: Float, _ unit: UnitLength) -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 2
        let measurement = Measurement(value: .init(lineLength),
                                      unit: UnitLength.meters)
        return formatter.string(from: measurement.converted(to: unit))
    }
}
