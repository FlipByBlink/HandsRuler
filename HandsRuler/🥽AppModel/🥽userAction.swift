import RealityKit
import ARKit
import Foundation

extension 🥽AppModel {
    func tap(_ fingerTipEntity: Entity) {
        self.logIfNeeded(fingerTipEntity)
        switch fingerTipEntity.name {
            case "left":
                switch self.selection {
                    case .left: self.unselect(fingerTipEntity)
                    case .right: self.reset()
                    case .noSelect: self.select(fingerTipEntity)
                }
            case "right":
                switch self.selection {
                    case .left: self.reset()
                    case .right: self.unselect(fingerTipEntity)
                    case .noSelect: self.select(fingerTipEntity)
                }
            default:
                fatalError()
        }
    }
    
    func unselect(_ entity: Entity) {
        self.selection = .noSelect
        entity.components.set(🧩Model.fingerTip(.blue))
        entity.playAudio(self.sounds.unselect)
    }
}

private extension 🥽AppModel {
    private func select(_ entity: Entity) {
        self.setCooldownState()
        switch entity.name {
            case "left": self.selection = .left
            case "right": self.selection = .right
            default: fatalError()
        }
        entity.components.set(🧩Model.fingerTip(.red))
        entity.playAudio(self.sounds.select)
    }
    
    private func reset() {
        self.selection = .noSelect
        self.entities.left.components.set(🧩Model.fingerTip(.blue))
        self.entities.right.components.set(🧩Model.fingerTip(.blue))
        
        self.entities.hideAndShow()
        self.resetPosition_simulator()
    }
    
    private func logIfNeeded(_ entity: Entity) {
        let condition: Bool = {
            switch entity.name {
                case "left": self.selection.isRight
                case "right": self.selection.isLeft
                default: fatalError()
            }
        }()
        if condition {
            self.playSecondFixingSound()
            let worldAnchor = WorldAnchor(originFromAnchorTransform: Transform().matrix)
            self.logs.add(💾Log(worldAnchorID: worldAnchor.id,
                                leftPosition: self.entities.left.position,
                                rightPosition: self.entities.right.position,
                                date: .now))
            self.addTracking(worldAnchor)
        }
    }
    
    private func playSecondFixingSound() {
        let entity = Entity()
        self.entities.root.addChild(entity)
        switch self.selection {
            case .left: entity.position = self.entities.right.position
            case .right: entity.position = self.entities.left.position
            case .noSelect: break
        }
        entity.playAudio(self.sounds.fix)
        Task {
            try? await Task.sleep(for: .seconds(2))
            entity.removeFromParent()
        }
    }
}
