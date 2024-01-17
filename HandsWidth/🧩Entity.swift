import RealityKit
import ARKit

enum 🧩Entity {
    static func fingerTips() -> [HandAnchor.Chirality: Entity] {
        [.left: Self.fingerTip(name: Self.Name.fingerTipLeft),
         .right: Self.fingerTip(name: Self.Name.fingerTipRight)]
    }
    static func line() -> Entity {
        let value = Entity()
        value.name = Self.Name.line
        value.components.set(OpacityComponent(opacity: 0.5))
        value.addChild(ModelEntity(mesh: .generateSphere(radius: 0.08),
                                   materials: [OcclusionMaterial()]))
        return value
    }
    enum Name {
        static let fingerTipLeft = "fingerTipLeft"
        static let fingerTipRight = "fingerTipRight"
        static let line = "line"
        static let resultLabel = "resultLabel"
    }
}

fileprivate extension 🧩Entity {
    private static func fingerTip(name: String) -> Entity {
        let value = ModelEntity(mesh: .generateSphere(radius: 0.01),
                                materials: [SimpleMaterial(color: .blue, isMetallic: false)])
        value.name = name
        value.components.set([InputTargetComponent(),
                              CollisionComponent(shapes: [.generateSphere(radius: 0.04)]),
                              HoverEffectComponent()])
        return value
    }
}
