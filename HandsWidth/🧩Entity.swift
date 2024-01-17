import RealityKit
import ARKit

enum 🧩Entity {
    static func fingerTips() -> [HandAnchor.Chirality: Entity] {
        [.left: Self.fingerTip(name: 🧩Name.fingerLeft),
         .right: Self.fingerTip(name: 🧩Name.fingerRight)]
    }
    static func line() -> Entity {
        let value = Entity()
        value.name = 🧩Name.line
        value.components.set(OpacityComponent(opacity: 0.5))
        value.addChild(ModelEntity(mesh: .generateSphere(radius: 0.08),
                                   materials: [OcclusionMaterial()]))
        return value
    }
}

fileprivate extension 🧩Entity {
    private static func fingerTip(name: String) -> Entity {
        let value = Entity()
        value.name = name
        value.components.set([InputTargetComponent(),
                              CollisionComponent(shapes: [.generateSphere(radius: 0.04)]),
                              HoverEffectComponent(),
                              🧩Model.fingerTip()])
        return value
    }
}
