import Foundation

enum 📐Unit: String {
    case meters,
         centiMeters,
         yards,
         feet,
         inches,
         feetAndInches
}

extension 📐Unit: CaseIterable, Identifiable {
    var id: Self { self }
    var value: UnitLength {
        switch self {
            case .meters: .meters
            case .centiMeters: .centimeters
            case .yards: .yards
            case .feet: .feet
            case .inches: .inches
            case .feetAndInches: fatalError()
        }
    }
    var symbol: String {
        switch self {
            case .feetAndInches:
                "\(Self.feet.symbol) & \(Self.inches.symbol)"
            default:
                self.value.symbol
        }
    }
    var title: LocalizedStringResource {
        switch self {
            case .meters: "Meters"
            case .centiMeters: "Centimeters"
            case .yards: "Yards"
            case .feet: "Feet"
            case .inches: "Inches"
            case .feetAndInches: "Feet & Inches"
        }
    }
}
