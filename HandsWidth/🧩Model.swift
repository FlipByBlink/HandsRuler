import RealityKit

enum 🧩Model {
    static func fingerTip(_ selected: Bool = false) -> ModelComponent {
        .init(mesh: .generateSphere(radius: 0.01),
              materials: [SimpleMaterial(color: selected ? .red : .blue,
                                         isMetallic: false)])
    }
}
