import RealityKit
import ARKit

enum 🧩Entity {
    static func line() -> Entity {
        let value = Entity()
        value.components.set(OpacityComponent(opacity: 0.75))
        let occlusionEntity = Entity()
        occlusionEntity.name = "lineOcclusion"
        occlusionEntity.components.set(🧩Model.lineOcclusion(Self.Placeholder.lineLength))
        value.addChild(occlusionEntity)
        return value
    }
    static func updateLine(_ entity: Entity, _ leftPosition: SIMD3<Float>, _ rightPosition: SIMD3<Float>) {
        let centerPosition = (leftPosition + rightPosition) / 2
        entity.position = centerPosition
        let lineLength = distance(leftPosition, rightPosition)
        entity.components.set(🧩Model.line(lineLength))
        entity.look(at: leftPosition, from: centerPosition, relativeTo: nil)
        let occlusionEntity = entity.findEntity(named: "lineOcclusion")!
        occlusionEntity.components[ModelComponent.self] = 🧩Model.lineOcclusion(lineLength)
        occlusionEntity.look(at: leftPosition, from: centerPosition, relativeTo: nil)
    }
    static func fingerTip(_ chirality: HandAnchor.Chirality) -> Entity {
        let value = Entity()
        switch chirality {
            case .left:
                value.name = "left"
                value.position = Self.Placeholder.leftPosition
            case .right:
                value.name = "right"
                value.position = Self.Placeholder.rightPosition
        }
        value.components.set([InputTargetComponent(allowedInputTypes: .indirect),
                              CollisionComponent(shapes: [.generateSphere(radius: 0.04)]),
                              HoverEffectComponent(),
                              🧩Model.fingerTip()])
        return value
    }
    static func fixedLine(_ log: 💾Log) -> Entity {
        let lineEntity = Self.line()
        Self.updateLine(lineEntity, log.leftPosition, log.rightPosition)
        return lineEntity
    }
    static func fixedPointer(_ position: SIMD3<Float>) -> Entity {
        let value = Entity()
        value.position = position
        value.components.set(🧩Model.fixedPointer())
        return value
    }
    static func fixedRuler(_ log: 💾Log, _ worldAnchor: WorldAnchor) -> Entity {
        let value = Entity()
        value.name = "fixedRuler\(log.worldAnchorID)"
        value.setTransformMatrix(worldAnchor.originFromAnchorTransform, relativeTo: nil)
        let lineEntity = 🧩Entity.line()
        🧩Entity.updateLine(lineEntity, log.leftPosition, log.rightPosition)
        value.addChild(lineEntity)
        value.addChild(🧩Entity.fixedPointer(log.leftPosition))
        value.addChild(🧩Entity.fixedPointer(log.rightPosition))
        return value
    }
    enum Placeholder {
        static let leftPosition: SIMD3<Float> = .init(x: -0.2, y: 1.5, z: -0.7)
        static let rightPosition: SIMD3<Float> = .init(x: 0.2, y: 1.5, z: -0.7)
        static var lineLength: Float { distance(Self.leftPosition, Self.rightPosition) }
    }
}
