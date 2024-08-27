import RealityKit

enum 🧩Model {
    static func fingerTip(_ color: SimpleMaterial.Color = .blue) -> ModelComponent {
        .init(mesh: .generateSphere(radius: 0.01),
              materials: [SimpleMaterial(color: color, isMetallic: false)])
    }
    static func fixedPointer() -> ModelComponent {
        .init(mesh: .generateSphere(radius: 0.01),
              materials: [SimpleMaterial(color: .white, isMetallic: false)])
    }
}
