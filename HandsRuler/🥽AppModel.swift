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
    
    private let arKitSession = ARKitSession()
    private let handTrackingProvider = HandTrackingProvider()
    private let worldTrackingProvider = WorldTrackingProvider()
    
    let entities = 🧩Entities()
    
    private var selection: 🔵Selection = .noSelect
    private let sounds = 📢Sounds()
}

extension 🥽AppModel {
    func runARKitSession() {
#if targetEnvironment(simulator)
        print("Not support ARKit tracking in simulator.")
#else
        Task { @MainActor in
            do {
                try await self.arKitSession.runARKitSession([self.handTrackingProvider,
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
                    self.entities.left.setTransformMatrix(originFromIndex, relativeTo: nil)
                case .right:
                    self.entities.right.setTransformMatrix(originFromIndex, relativeTo: nil)
            }
            
            self.updateRuler()
        }
    }
    
    private func processWorldAnchorUpdates() async {
        for await update in self.worldTrackingProvider.anchorUpdates {
            self.entities.applyWorldAnchorUpdates(self.logs, update)
        }
    }
    
    private func updateRuler() {
        self.entities.updateRuler()
        self.resultValue = distance(self.entities.left.position, self.entities.right.position)
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
            self.logs.add(💾Log(anchorID: worldAnchor.id,
                                leftPosition: self.entities.left.position,
                                rightPosition: self.entities.right.position,
                                date: .now))
            Task { try? await self.worldTrackingProvider.addAnchor(worldAnchor) }
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




//MARK: ====== simulator ======
extension 🥽AppModel {
    func setUp_simulator() {
#if targetEnvironment(simulator)
        self.updateRuler()
#endif
    }
    func setRandomPosition_simulator() {
#if targetEnvironment(simulator)
        if !self.selection.isLeft {
            self.entities.left.position = .init(x: .random(in: -0.8 ..< -0.05),
                                             y: .random(in: 1 ..< 1.5),
                                             z: .random(in: -1 ..< -0.5))
        }
        if !self.selection.isRight {
            self.entities.right.position = .init(x: .random(in: 0.05 ..< 0.8),
                                              y: .random(in: 1 ..< 1.5),
                                              z: .random(in: -1 ..< -0.5))
        }
        self.updateRuler()
#endif
    }
    private func resetPosition_simulator() {
#if targetEnvironment(simulator)
        self.entities.left.position = 🧩Entity.Placeholder.leftPosition
        self.entities.right.position = 🧩Entity.Placeholder.rightPosition
        self.updateRuler()
#endif
    }
}
