import RealityKit
import ARKit

enum 🧩Entity {
    static func line() -> Entity {
        let value = Entity()
        value.components.set(OpacityComponent(opacity: 0.75))
        value.addChild(Self.lineOcclusion(0.4))
        return value
    }
    static func lineOcclusion(_ lineLength: Float) -> Entity {
        let value = Entity()
        value.name = "lineOcclusion"
        value.components.set(🧩Model.lineOcclusion(lineLength))
        return value
    }
    static func fingerTip(_ chirality: HandAnchor.Chirality) -> Entity {
        let value = Entity()
        switch chirality {
            case .left:
                value.name = "left"
                value.position = .init(x: -0.2, y: 1.5, z: -0.7)
            case .right:
                value.name = "right"
                value.position = .init(x: 0.2, y: 1.5, z: -0.7)
        }
        value.components.set([InputTargetComponent(allowedInputTypes: .indirect),
                              CollisionComponent(shapes: [.generateSphere(radius: 0.04)]),
                              HoverEffectComponent(),
                              🧩Model.fingerTip()])
        return value
    }
    static func fixedPointer(_ position: SIMD3<Float>) -> Entity {
        let value = Entity()
        value.position = position
        value.components.set(🧩Model.fixedPointer())
        return value
    }
}
