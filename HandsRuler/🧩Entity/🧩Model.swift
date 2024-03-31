import RealityKit

enum 🧩Model {
    static func line(_ length: Float) -> ModelComponent {
        ModelComponent(mesh: .generateBox(width: 0.01,
                                          height: 0.01,
                                          depth: length,
                                          cornerRadius: 0.005),
                       materials: [SimpleMaterial(color: .white, isMetallic: false)])
    }
    static func lineOcclusion(_ lineLength: Float) -> ModelComponent {
        ModelComponent(mesh: .generateSphere(radius: 0.04 + lineLength * 0.05),
                       materials: [OcclusionMaterial()])
    }
    static func fingerTip(_ color: SimpleMaterial.Color = .blue) -> ModelComponent {
        .init(mesh: .generateSphere(radius: 0.01),
              materials: [SimpleMaterial(color: color, isMetallic: false)])
    }
    static func fixedPointer() -> ModelComponent {
        .init(mesh: .generateSphere(radius: 0.01),
              materials: [SimpleMaterial(color: .yellow, isMetallic: false)])
    }
}
