import Foundation

enum 📏Unit: String {
    case meters, centiMeters, feet, inches
}

extension 📏Unit: CaseIterable, Identifiable {
    var id: Self { self }
    var value: UnitLength {
        switch self {
            case .meters: .meters
            case .centiMeters: .centimeters
            case .feet: .feet
            case .inches: .inches
        }
    }
}
