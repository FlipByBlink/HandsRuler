import Foundation

struct 💾Log: Codable {
    var leftID: UUID
    var rightID: UUID
    var lineLength: Float
    var rotationRadians: Double
    var date: Date
}
