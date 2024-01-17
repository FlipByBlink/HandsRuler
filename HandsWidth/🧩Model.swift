import RealityKit

enum 🧩Model {
    static func fingerTip(_ selected: Bool = false) -> ModelComponent {
        .init(mesh: .generateSphere(radius: 0.01),
              materials: [SimpleMaterial(color: selected ? .red : .blue,
                                         isMetallic: false)])
    }
    static func line(_ leftPosition: SIMD3<Float>, _ rightPosition: SIMD3<Float>) -> ModelComponent {
        ModelComponent(mesh: .generateBox(width: 0.01,
                                          height: 0.01,
                                          depth: distance(leftPosition, rightPosition),
                                          cornerRadius: 0.005),
                       materials: [SimpleMaterial(color: .white, isMetallic: false)])
    }
}
