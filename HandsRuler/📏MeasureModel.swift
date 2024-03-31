import SwiftUI
import RealityKit
import ARKit

@MainActor
class 📏MeasureModel: ObservableObject {
    @AppStorage("unit") var unit: 📐Unit = .meters
    
    @Published var resultValue: Float = 0.4
    @Published var selectedLeft: Bool = false
    @Published var selectedRight: Bool = false
    
    private let session = ARKitSession()
    private let handTrackingProvider = HandTrackingProvider()
    private let worldTrackingProvider = WorldTrackingProvider()
    
    let rootEntity = Entity()
    private let lineEntity = 🧩Entity.line()
    private let leftEntity = 🧩Entity.fingerTip(.left)
    private let rightEntity = 🧩Entity.fingerTip(.right)
    
    let sounds = 📢Sounds()
}

extension 📏MeasureModel {
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
    
    func tap(_ entity: Entity) {
        switch entity.name {
            case "left":
                if self.selectedRight {
                    self.unselectAll()
                } else {
                    self.select(entity, &self.selectedLeft)
                }
            case "right":
                if self.selectedLeft {
                    self.unselectAll()
                } else {
                    self.select(entity, &self.selectedRight)
                }
            default:
                assertionFailure()
                break
        }
    }
    
    func shouldLog(_ entity: Entity) -> Bool {
        switch entity.name {
            case "left": self.selectedRight
            case "right": self.selectedLeft
            default: fatalError()
        }
    }
    
    func createLog() -> 💾Log {
        let leftAnchor = WorldAnchor(originFromAnchorTransform: self.leftEntity.transform.matrix)
        let rightAnchor = WorldAnchor(originFromAnchorTransform: self.rightEntity.transform.matrix)
        let centerMatrix = Transform(translation: self.centerPosition).matrix
        let centerAnchor = WorldAnchor(originFromAnchorTransform: centerMatrix)
        self.rootEntity.addChild(🧩Entity.fixedPointer(leftAnchor))
        self.rootEntity.addChild(🧩Entity.fixedPointer(rightAnchor))
        self.rootEntity.addChild(🧩Entity.fixedCenter(centerAnchor))
        return .init(leftID: leftAnchor.id,
                     rightID: rightAnchor.id,
                     centerID: centerAnchor.id,
                     lineLength: self.lineLength,
                     rotationRadians: self.rotation,
                     date: .now)
    }
}

private extension 📏MeasureModel {
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
                    continue
                case .removed:
                    guard let entity = self.rootEntity.findEntity(named: "\(update.anchor.id)") else {
                        assertionFailure()
                        continue
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
        let occlusionEntity = self.lineEntity.findEntity(named: "lineOcclusion")!
        occlusionEntity.components[ModelComponent.self] = 🧩Model.lineOcclusion(self.lineLength)
    }
    
    private func updateResult() {
        self.rootEntity.findEntity(named: "result")?.position = self.centerPosition
        self.resultValue = self.lineLength
    }
    
    private var lineLength: Float {
        distance(self.leftEntity.position, self.rightEntity.position)
    }
    
    private var centerPosition: SIMD3<Float> {
        (self.leftEntity.position + self.rightEntity.position) / 2
    }
    
    private var rotation: Double {
        .init(
            asin(
                (self.rightEntity.position.y - self.leftEntity.position.y)
                /
                distance(self.leftEntity.position, self.rightEntity.position)
            )
        )
    }
    
    private func select(_ entity: Entity, _ selection: inout Bool) {
        selection.toggle()
        entity.components.set(🧩Model.fingerTip(selection))
        entity.playAudio(self.sounds[selection])
    }
    
    private func unselectAll() {
        self.selectedLeft = false
        self.leftEntity.components.set(🧩Model.fingerTip(false))
        self.selectedRight = false
        self.rightEntity.components.set(🧩Model.fingerTip(false))
    }
    
    private func updateFixedLinesAndResults() {
        //placeholder
    }
}




//MARK: Simulator
extension 📏MeasureModel {
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
