import RealityKit
import ARKit

enum 🧩Entity {
    static func line() -> Entity {
        let value = Entity()
        value.components.set(OpacityComponent(opacity: Self.lineOpacity))
        
        ["pieceA", "pieceB"].forEach {
            let partEntity = Entity()
            partEntity.name = $0
            partEntity.components.set(🧩Model.oneMeterCylinder())
            partEntity.orientation = .init(angle: .pi / 2, axis: [1, 0, 0])
            value.addChild(partEntity)
        }
        
        return value
    }
    
    static func updateLine(_ entity: Entity,
                           _ leftPosition: SIMD3<Float>,
                           _ rightPosition: SIMD3<Float>) {
        let centerPosition = (leftPosition + rightPosition) / 2
        entity.position = centerPosition
        let lineLength = distance(leftPosition, rightPosition)
        
        ["pieceA", "pieceB"].forEach {
            let partEntity = entity.findEntity(named: $0)!
            partEntity.position.z = lineLength / 3
            if $0 == "pieceB" { partEntity.position.z *= -1 }
            partEntity.scale.y = lineLength / 3
        }
        
        if lineLength < 0.12 {
            let newOpacity = Self.lineOpacity * (lineLength / 0.12)
            entity.components.set(OpacityComponent(opacity: newOpacity))
        } else {
            entity.components.set(OpacityComponent(opacity: Self.lineOpacity))
        }
        
        entity.look(at: leftPosition, from: centerPosition, relativeTo: nil)
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
}

private extension 🧩Entity {
    private static let lineOpacity: Float = 0.75
    
    private enum Placeholder {
        static let leftPosition: SIMD3<Float> = .init(x: -0.2, y: 1.5, z: -0.7)
        static let rightPosition: SIMD3<Float> = .init(x: 0.2, y: 1.5, z: -0.7)
        static var lineLength: Float { distance(Self.leftPosition, Self.rightPosition) }
    }
}
