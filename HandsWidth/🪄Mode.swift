import SwiftUI

enum 🪄Mode: String {
    case handToHand, handToGround
}

extension 🪄Mode: CaseIterable, Identifiable {
    var id: Self { self }
    var localizedTitle: LocalizedStringResource {
        switch self {
            case .handToHand: "Hand to hand"
            case .handToGround: "Hand to ground"
        }
    }
}
