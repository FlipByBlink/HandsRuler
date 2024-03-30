import RealityKit
import Foundation

enum 🧩Component {
    struct FixedLine: Component, Codable {
        let firstPointerWorldAnchorID: UUID
        let secondPointerWorldAnchorID: UUID
        init(_ first: UUID, _ second: UUID) {
            self.firstPointerWorldAnchorID = first
            self.secondPointerWorldAnchorID = second
        }
    }
}
