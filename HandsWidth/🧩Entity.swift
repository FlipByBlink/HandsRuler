import RealityKit
import ARKit

enum 🧩Entity {
    static func fingerTips() -> [HandAnchor.Chirality: Entity] {
        [.left: Self.fingerTip(name: "left"),
         .right: Self.fingerTip(name: "right")]
    }
    static func line() -> Entity {
        let value = Entity()
        value.name = "line"
        value.components.set(OpacityComponent(opacity: 0.5))
        value.addChild(ModelEntity(mesh: .generateSphere(radius: 0.08),
                                   materials: [OcclusionMaterial()]))
        return value
    }
}

fileprivate extension 🧩Entity {
    private static func fingerTip(name: String) -> Entity {
        let value = ModelEntity(mesh: .generateSphere(radius: 0.01),
                                materials: [SimpleMaterial(color: .blue, isMetallic: false)])
        value.name = name
        value.components.set([InputTargetComponent(),
                              CollisionComponent(shapes: [.generateSphere(radius: 0.1)]),
                              HoverEffectComponent()])
        return value
    }
}
