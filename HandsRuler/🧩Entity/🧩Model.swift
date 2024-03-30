import RealityKit

enum 🧩Model {
    static func line(_ length: Float) -> ModelComponent {
        ModelComponent(mesh: .generateBox(width: 0.01,
                                          height: 0.01,
                                          depth: length,
                                          cornerRadius: 0.005),
                       materials: [SimpleMaterial(color: .white, isMetallic: false)])
    }
    static func fingerTip(_ selected: Bool = false) -> ModelComponent {
        .init(mesh: .generateSphere(radius: 0.01),
              materials: [SimpleMaterial(color: selected ? .red : .blue,
                                         isMetallic: false)])
    }
    static func fixedPointer() -> ModelComponent {
        .init(mesh: .generateSphere(radius: 0.01),
              materials: [SimpleMaterial(color: .white, isMetallic: false)])
    }
}
