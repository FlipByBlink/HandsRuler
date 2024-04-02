import RealityKit

enum 🧩Model {
    static func line(_ length: Float) -> ModelComponent {
        .init(mesh: .generateBox(width: 0.01,
                                 height: 0.01,
                                 depth: length,
                                 cornerRadius: 0.005),
              materials: [SimpleMaterial(color: .white, isMetallic: false)])
    }
    static func lineOcclusion(_ lineLength: Float) -> ModelComponent {
        .init(mesh: .generateBox(width: 0.02,
                                 height: 0.02,
                                 depth: 0.08 + lineLength * 0.1),
              materials: [OcclusionMaterial()])
    }
    static func fingerTip(_ color: SimpleMaterial.Color = .blue) -> ModelComponent {
        .init(mesh: .generateSphere(radius: 0.01),
              materials: [SimpleMaterial(color: color, isMetallic: false)])
    }
    static func fixedPointer() -> ModelComponent {
        .init(mesh: .generateSphere(radius: 0.01),
              materials: [SimpleMaterial(color: .white, isMetallic: false)])
    }
}
