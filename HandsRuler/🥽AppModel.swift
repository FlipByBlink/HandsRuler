import SwiftUI
import RealityKit
import ARKit

@MainActor
class 🥽AppModel: ObservableObject {
    @AppStorage("unit") var unit: 📐Unit = .meters
    @AppStorage("measureOnLaunch") var measureOnLaunch: Bool = false
    
    @Published private(set) var resultValue: Float = 0.4
    @Published var openedImmersiveSpace: Bool = false
    @Published var logs: 💾Logs = .load()
    
    private let session = ARKitSession()
    private let handTrackingProvider = HandTrackingProvider()
    private let worldTrackingProvider = WorldTrackingProvider()
    
    let rootEntity = Entity()
    private let lineEntity = 🧩Entity.line()
    private let leftEntity = 🧩Entity.fingerTip(.left)
    private let rightEntity = 🧩Entity.fingerTip(.right)
    
    private var selection: 🔵Selection = .noSelect
    private let sounds = 📢Sounds()
}

extension 🥽AppModel {
    func setUpChildEntities() {
        self.rootEntity.addChild(self.lineEntity)
        self.rootEntity.addChild(self.leftEntity)
        self.rootEntity.addChild(self.rightEntity)
    }
    
    func run() {
#if targetEnvironment(simulator)
        print("Not support ARKit tracking in simulator.")
#else
        Task { @MainActor in
            do {
                try await self.session.run([self.handTrackingProvider,
                                            self.worldTrackingProvider])
                Task { await self.processHandUpdates() }
                Task { await self.processWorldAnchorUpdates() }
            } catch {
                print(error)
            }
        }
#endif
    }
    
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
    
    func removeLog(_ log: 💾Log) {
        self.logs.remove(log)
        Task { try? await self.worldTrackingProvider.removeAnchor(forID: log.id) }
    }
    
    func removeLog(_ indexSet: IndexSet) {
        indexSet.forEach { self.removeLog(self.logs.elements[$0]) }
    }
    
    func clearLogs() {
        Task {
            for log in self.logs.elements {
                try? await self.worldTrackingProvider.removeAnchor(forID: log.id)
            }
        }
        self.logs.clear()
    }
}

//MARK: ====== private ======
private extension 🥽AppModel {
    private func processHandUpdates() async {
        for await update in self.handTrackingProvider.anchorUpdates {
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked,
                  let fingerTip = handAnchor.handSkeleton?.joint(.indexFingerTip),
                  fingerTip.isTracked else {
                continue
            }
            
            if self.selection.isLeft, handAnchor.chirality == .left { continue }
            if self.selection.isRight, handAnchor.chirality == .right { continue }
            
            let originFromWrist = handAnchor.originFromAnchorTransform
            
            let wristFromIndex = fingerTip.anchorFromJointTransform
            let originFromIndex = originFromWrist * wristFromIndex
            
            switch handAnchor.chirality {
                case .left:
                    self.leftEntity.setTransformMatrix(originFromIndex, relativeTo: nil)
                case .right:
                    self.rightEntity.setTransformMatrix(originFromIndex, relativeTo: nil)
            }
            
            self.updateLine()
            self.updateResultBoard()
        }
    }
    
    private func processWorldAnchorUpdates() async {
        for await update in self.worldTrackingProvider.anchorUpdates {
            switch update.event {
                case .added:
                    self.setFixedRuler(update.anchor)
                    self.setFixedResultBoard(update.anchor)
                case .updated:
                    self.updateFixedRuler(update.anchor)
                    self.updateFixedResultBoard(update.anchor)
                case .removed:
                    self.removeFixedRuler(update.anchor)
                    self.removeFixedResultBoard(update.anchor)
            }
        }
    }
    
    private func updateLine() {
        🧩Entity.updateLine(self.lineEntity,
                            self.leftEntity.position,
                            self.rightEntity.position)
    }
    
    private func updateResultBoard() {
        let centerPosition = (self.leftEntity.position + self.rightEntity.position) / 2
        self.rootEntity.findEntity(named: "resultBoard")?.position = centerPosition
        self.resultValue = distance(self.leftEntity.position, self.rightEntity.position)
    }
    
    private func select(_ entity: Entity) {
        switch entity.name {
            case "left": self.selection = .left
            case "right": self.selection = .right
            default: fatalError()
        }
        entity.components.set(🧩Model.fingerTip(.red))
        entity.playAudio(self.sounds.select)
    }
    
    private func unselect(_ entity: Entity) {
        self.selection = .noSelect
        entity.components.set(🧩Model.fingerTip(.blue))
        entity.playAudio(self.sounds.unselect)
    }
    
    private func reset() {
        self.selection = .noSelect
        self.leftEntity.components.set(🧩Model.fingerTip(.blue))
        self.rightEntity.components.set(🧩Model.fingerTip(.blue))
        
        self.hideAndShow()
        self.resetPosition_simulator()
    }
    
    private func hideAndShow() {
        Task {
            let entities = [
                self.lineEntity,
                self.leftEntity,
                self.rightEntity,
                self.rootEntity.findEntity(named: "resultBoard")!
            ]
            entities.forEach { $0.isEnabled = false }
            try await Task.sleep(for: .seconds(2.5))
            entities.forEach { $0.isEnabled = true }
        }
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
            self.logs.add(💾Log(anchorID: worldAnchor.id,
                                leftPosition: self.leftEntity.position,
                                rightPosition: self.rightEntity.position,
                                date: .now))
            Task { try? await self.worldTrackingProvider.addAnchor(worldAnchor) }
        }
    }
    
    private func playSecondFixingSound() {
        let entity = Entity()
        self.rootEntity.addChild(entity)
        switch self.selection {
            case .left: entity.position = self.rightEntity.position
            case .right: entity.position = self.leftEntity.position
            case .noSelect: break
        }
        entity.playAudio(self.sounds.fix)
        Task {
            try? await Task.sleep(for: .seconds(2))
            entity.removeFromParent()
        }
    }
    
    private func setFixedRuler(_ worldAnchor: WorldAnchor) {
        if let log = self.logs[worldAnchor.id] {
            self.rootEntity.addChild(🧩Entity.fixedRuler(log, worldAnchor))
        }
    }
    
    private func updateFixedRuler(_ worldAnchor: WorldAnchor) {
        if let log = self.logs[worldAnchor.id],
           let fixedRulerEntity = self.rootEntity.findEntity(named: "fixedRuler\(log.id)") {
            fixedRulerEntity.removeFromParent()
            self.rootEntity.addChild(🧩Entity.fixedRuler(log, worldAnchor))
        }
    }
    
    private func removeFixedRuler(_ worldAnchor: WorldAnchor) {
        if let log = self.logs[worldAnchor.id],
           let fixedRulerEntity = self.rootEntity.findEntity(named: "fixedRuler\(log.id)") {
            fixedRulerEntity.removeFromParent()
        }
    }
    
    private func setFixedResultBoard(_ worldAnchor: WorldAnchor) {//TODO: Work in progress
        if let log = self.logs[worldAnchor.id],
           let fixedResultBoardEntity = self.rootEntity.findEntity(named: "fixedResultBoard\(log.id)") {
            fixedResultBoardEntity.setTransformMatrix(worldAnchor.originFromAnchorTransform, relativeTo: nil)
            fixedResultBoardEntity.setPosition(log.centerPosition,
                                               relativeTo: fixedResultBoardEntity)
            self.rootEntity.addChild(fixedResultBoardEntity)
        }
    }
    
    private func updateFixedResultBoard(_ worldAnchor: WorldAnchor) {//TODO: Work in progress
        if let log = self.logs[worldAnchor.id],
           let fixedResultBoardEntity = self.rootEntity.findEntity(named: "fixedResultBoard\(log.id)") {
            fixedResultBoardEntity.setTransformMatrix(worldAnchor.originFromAnchorTransform, relativeTo: nil)
            fixedResultBoardEntity.setPosition(log.centerPosition,
                                               relativeTo: fixedResultBoardEntity)
        }
    }
    
    private func removeFixedResultBoard(_ worldAnchor: WorldAnchor) {//TODO: Work in progress
        if let log = self.logs[worldAnchor.id],
           let fixedResultBoardEntity = self.rootEntity.findEntity(named: "fixedResultBoard\(log.id)") {
            fixedResultBoardEntity.removeFromParent()
        }
    }
}




//MARK: ====== simulator ======
extension 🥽AppModel {
    func setUp_simulator() {
#if targetEnvironment(simulator)
        self.updateLine()
        self.updateResultBoard()
#endif
    }
    func setRandomPosition_simulator() {
#if targetEnvironment(simulator)
        if !self.selection.isLeft {
            self.leftEntity.position = .init(x: .random(in: -0.8 ..< -0.05),
                                             y: .random(in: 1 ..< 1.5),
                                             z: .random(in: -1 ..< -0.5))
        }
        if !self.selection.isRight {
            self.rightEntity.position = .init(x: .random(in: 0.05 ..< 0.8),
                                              y: .random(in: 1 ..< 1.5),
                                              z: .random(in: -1 ..< -0.5))
        }
        self.updateLine()
        self.updateResultBoard()
#endif
    }
    private func resetPosition_simulator() {
#if targetEnvironment(simulator)
        self.leftEntity.position = 🧩Entity.Placeholder.leftPosition
        self.rightEntity.position = 🧩Entity.Placeholder.rightPosition
        self.updateLine()
        self.updateResultBoard()
#endif
    }
}
