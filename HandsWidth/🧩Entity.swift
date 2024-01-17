import RealityKit
import ARKit

enum 🧩Entity {
    static func fingerTips() -> [HandAnchor.Chirality: Entity] {
        [.left: Self.fingerTip(.left),
         .right: Self.fingerTip(.right)]
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
    private static func fingerTip(_ chirality: HandAnchor.Chirality) -> Entity {
        let value = Entity()
        switch chirality {
            case .left:
                value.name = 🧩Name.fingerLeft
                value.position = .init(x: -0.3, y: 1.5, z: -1)
            case .right:
                value.name = 🧩Name.fingerRight
                value.position = .init(x: 0.3, y: 1.5, z: -1)
        }
        value.components.set([InputTargetComponent(),
                              CollisionComponent(shapes: [.generateSphere(radius: 0.04)]),
                              HoverEffectComponent(),
                              🧩Model.fingerTip()])
        return value
    }
}
