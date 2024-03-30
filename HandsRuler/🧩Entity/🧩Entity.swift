import RealityKit
import ARKit

enum 🧩Entity {
    static func line() -> Entity {
        let value = Entity()
        value.components.set(OpacityComponent(opacity: 0.75))
        value.addChild(ModelEntity(mesh: .generateSphere(radius: 0.06),
                                   materials: [OcclusionMaterial()]))
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
    static func fixedPointer(_ worldAnchor: WorldAnchor) -> Entity {
        let value = ModelEntity(mesh: .generateSphere(radius: 0.01),
                                materials: [SimpleMaterial(color: .gray,
                                                           isMetallic: false)])
        value.name = "\(worldAnchor.id)"
        value.transform = .init(matrix: worldAnchor.originFromAnchorTransform)
        return value
    }
}
