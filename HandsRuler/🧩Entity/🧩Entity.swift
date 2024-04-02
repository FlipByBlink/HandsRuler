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
    static func fixedPointer(_ position: SIMD3<Float>) -> Entity {
        let value = Entity()
        value.position = position
        value.components.set(🧩Model.fixedPointer())
        return value
    }
    static func fixedLine(_ log: 💾Log) -> Entity {
        let lineEntity = Self.line()
        Self.updateLine(lineEntity, log.leftPosition, log.rightPosition)
        return lineEntity
    }
//    static func fixedRuler(_ leftPosition: SIMD3<Float>, _ rightPosition: SIMD3<Float>) -> Entity {
//        let value = Entity()
//        let lineEntity = Self.line()
//        Self.updateLine(lineEntity, leftPosition, rightPosition)
//        value.addChild(lineEntity)
//        let fixedLeftEntity = Self.fixedPointer(leftPosition)
//        value.addChild(fixedLeftEntity)
//        let fixedRightEntity = Self.fixedPointer(rightPosition)
//        value.addChild(fixedRightEntity)
//        value.components.set(AnchoringComponent(.world(transform: Transform().matrix)))
//        return value
//    }
    enum Placeholder {
        static let leftPosition: SIMD3<Float> = .init(x: -0.2, y: 1.5, z: -0.7)
        static let rightPosition: SIMD3<Float> = .init(x: 0.2, y: 1.5, z: -0.7)
        static var lineLength: Float { distance(Self.leftPosition, Self.rightPosition) }
    }
}
