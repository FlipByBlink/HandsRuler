import RealityKit
import Foundation

struct 🪧FixedResultBoardComponent: Component, Codable { //MARK: Work in progress
    var worldAnchorID: UUID
    init(_ worldAnchorID: UUID) {
        self.worldAnchorID = worldAnchorID
    }
}
