import SwiftUI

struct 💾Log: Codable {
    let worldAnchorID: UUID
    let leftPosition: SIMD3<Float>
    let rightPosition: SIMD3<Float>
    let date: Date
}

extension 💾Log: Hashable {
    var lineLength: Float {
        distance(self.leftPosition, self.rightPosition)
    }
    var centerPosition: SIMD3<Float> {
        (self.leftPosition + self.rightPosition) / 2
    }
    var rotationRadians: Double {
        .init(
            asin(
                (self.rightPosition.y - self.leftPosition.y)
                /
                distance(self.leftPosition, self.rightPosition)
            )
        )
    }
}
