import RealityKit
import ARKit

@MainActor
class 🧩Entities {
    let root = Entity()
    let line = 🧩Entity.line()
    let left = 🧩Entity.fingerTip(.left)
    let right = 🧩Entity.fingerTip(.right)
}

extension 🧩Entities {
    func setUpChildren() {
        self.root.addChild(self.line)
        self.root.addChild(self.left)
        self.root.addChild(self.right)
    }
    var resultBoard: Entity? {
        self.root.findEntity(named: "resultBoard")
    }
    func add(_ entity: Entity) {
        self.root.addChild(entity)
    }
    func applyPointersUpdateToLineAndResultBoard() {
        🧩Entity.updateLine(self.line,
                            self.left.position,
                            self.right.position)
        
        self.resultBoard?.setPosition((self.left.position + self.right.position) / 2,
                                      relativeTo: nil)
    }
    func hideAndShow() {
        Task {
            let entities = [
                self.line,
                self.left,
                self.right,
                self.root.findEntity(named: "resultBoard")!
            ]
            entities.forEach { $0.isEnabled = false }
            try await Task.sleep(for: .seconds(2.5))
            entities.forEach { $0.isEnabled = true }
        }
    }
    func applyWorldAnchorUpdates(_ logs: 💾Logs, _ update: AnchorUpdate<WorldAnchor>) {
        switch update.event {
            case .added: self.setFixedRuler(logs, update.anchor)
            case .updated: self.updateFixedRuler(logs, update.anchor)
            case .removed: self.removeFixedRuler(logs, update.anchor)
        }
    }
    func setFixedRuler(_ logs: 💾Logs, _ worldAnchor: WorldAnchor) {
        if let log = logs[worldAnchor.id] {
            self.root.addChild(🧩Entity.fixedRuler(log, worldAnchor))
            
            if let fixedResultBoardEntity = self.root.findEntity(named: "fixedResultBoard\(log.id)") {
                fixedResultBoardEntity.setTransformMatrix(worldAnchor.originFromAnchorTransform, relativeTo: nil)
                fixedResultBoardEntity.setPosition(log.centerPosition, relativeTo: fixedResultBoardEntity)
            }
        }
    }
    func updateFixedRuler(_ logs: 💾Logs, _ worldAnchor: WorldAnchor) {
        if let log = logs[worldAnchor.id],
           let fixedRulerEntity = self.root.findEntity(named: "fixedRuler\(log.id)") {
            fixedRulerEntity.removeFromParent()
            self.root.addChild(🧩Entity.fixedRuler(log, worldAnchor))
            
            if let fixedResultBoardEntity = self.root.findEntity(named: "fixedResultBoard\(log.id)") {
                fixedResultBoardEntity.setTransformMatrix(worldAnchor.originFromAnchorTransform, relativeTo: nil)
                fixedResultBoardEntity.setPosition(log.centerPosition, relativeTo: fixedResultBoardEntity)
            }
        }
    }
    func removeFixedRuler(_ logs: 💾Logs, _ worldAnchor: WorldAnchor) {
        //TODO: 再検討
        if let log = logs[worldAnchor.id],
           let fixedRulerEntity = self.root.findEntity(named: "fixedRuler\(log.id)") {
            fixedRulerEntity.removeFromParent()
            
            if let fixedResultBoardEntity = self.root.findEntity(named: "fixedResultBoard\(log.id)") {
                fixedResultBoardEntity.removeFromParent()
            }
        }
    }
}
