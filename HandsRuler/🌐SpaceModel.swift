import SwiftUI
import RealityKit
import ARKit

@MainActor
class 🌐SpaceModel: ObservableObject {
    @AppStorage("unit") var unit: 📏Unit = .meters
    @AppStorage("logsData") var logsData: Data?
    
    @Published var resultModel: 🪧ResultModel = .placeholder
    @Published var selectedLeft: Bool = false
    @Published var selectedRight: Bool = false
    
    private let session = ARKitSession()
    private let handTrackingProvider = HandTrackingProvider()
    private let worldTrackingProvider = WorldTrackingProvider()
    
    let rootEntity = Entity()
    private let lineEntity = 🧩Entity.line()
    private let leftEntity = 🧩Entity.fingerTip(.left)
    private let rightEntity = 🧩Entity.fingerTip(.right)
    
    private let sounds = 📢Sounds()
}

extension 🌐SpaceModel {
    func setUpChildEntities() {
        self.rootEntity.addChild(self.lineEntity)
        self.rootEntity.addChild(self.leftEntity)
        self.rootEntity.addChild(self.rightEntity)
    }
    
    func run() {
#if targetEnvironment(simulator)
        print("Not support handTracking in simulator.")
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
    
    func changeSelection(_ targetedEntity: Entity) {
        switch targetedEntity.name {
            case "left":
                self.selectedLeft.toggle()
                self.leftEntity.components.set(🧩Model.fingerTip(self.selectedLeft))
                let player = targetedEntity.prepareAudio(self.sounds[self.selectedLeft])
                player.gain = -8
                player.play()
            case "right":
                self.selectedRight.toggle()
                self.rightEntity.components.set(🧩Model.fingerTip(self.selectedRight))
                let player = targetedEntity.prepareAudio(self.sounds[self.selectedRight])
                player.gain = -8
                player.play()
            default:
                assertionFailure()
                break
        }
    }
    
    var logs: 💾Logs { .load(self.logsData) }
}

private extension 🌐SpaceModel {
    private func processHandUpdates() async {
        for await update in self.handTrackingProvider.anchorUpdates {
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked,
                  let fingerTip = handAnchor.handSkeleton?.joint(.indexFingerTip),
                  fingerTip.isTracked else {
                continue
            }
            
            if self.selectedLeft, handAnchor.chirality == .left { continue }
            if self.selectedRight, handAnchor.chirality == .right { continue }
            
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
            self.updateResult()
        }
    }
    
    private func processWorldAnchorUpdates() async {
        for await update in self.worldTrackingProvider.anchorUpdates {
            switch update.event {
                case .added:
                    self.rootEntity.addChild(🧩Entity.fixedPointer(update.anchor))
                case .updated:
                    guard let entity = self.rootEntity.findEntity(named: "\(update.anchor.id)") else {
                        assertionFailure()
                        return
                    }
                    entity.transform = .init(matrix: update.anchor.originFromAnchorTransform)
                case .removed:
                    guard let entity = self.rootEntity.findEntity(named: "\(update.anchor.id)") else {
                        assertionFailure()
                        return
                    }
                    self.rootEntity.removeChild(entity)
            }
            self.updateFixedLinesAndResults()
        }
    }
    
    private func updateLine() {
        self.lineEntity.position = self.centerPosition
        self.lineEntity.components.set(🧩Model.line(self.lineLength))
        self.lineEntity.look(at: self.leftEntity.position,
                             from: self.centerPosition,
                             relativeTo: nil)
    }
    
    private func updateResult() {
        self.rootEntity.findEntity(named: "result")?.position = self.centerPosition
        self.resultModel = .init(self.lineLength, self.unit)
    }
    
    private var lineLength: Float {
        distance(self.leftEntity.position, self.rightEntity.position)
    }
    
    private var centerPosition: SIMD3<Float> {
        (self.leftEntity.position + self.rightEntity.position) / 2
    }
    
    private func updateFixedLinesAndResults() {
        //placeholder
    }
}




//MARK: Simulator
extension 🌐SpaceModel {
    func setUp_simulator() {
#if targetEnvironment(simulator)
        self.updateLine()
        self.updateResult()
#endif
    }
    func setRandomPosition_simulator() {
#if targetEnvironment(simulator)
        if !self.selectedLeft {
            self.leftEntity.position = .init(x: .random(in: -0.8 ..< -0.05),
                                             y: .random(in: 1 ..< 1.5),
                                             z: .random(in: -1 ..< -0.5))
        }
        if !self.selectedRight {
            self.rightEntity.position = .init(x: .random(in: 0.05 ..< 0.8),
                                              y: .random(in: 1 ..< 1.5),
                                              z: .random(in: -1 ..< -0.5))
        }
        self.updateLine()
        self.updateResult()
#endif
    }
}
