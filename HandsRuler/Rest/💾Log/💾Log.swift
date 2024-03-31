import Foundation

struct 💾Log: Codable {
    let leftID: UUID
    let rightID: UUID
    let centerID: UUID
    let lineLength: Float
    let rotationRadians: Double
    let date: Date
}

extension 💾Log: Identifiable, Hashable {
    var id: String { "\(self.leftID)\(self.rightID)" }
}
