import SwiftUI
import RealityKit
import ARKit

@MainActor
class 📏MeasureModel: ObservableObject {
    @AppStorage("unit") var unit: 📐Unit = .meters
    @AppStorage("logsData") var logsData: Data?
    
    @Published private(set) var resultValue: Float = 0.4
    
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
        self.logIfNeeded(entity)
        switch entity.name {
            case "left":
                switch self.selection {
                    case .left: self.unselect(entity)
                    case .right: self.reset()
                    case .noSelect: self.select(entity)
                }
            case "right":
                switch self.selection {
                    case .left: self.reset()
                    case .right: self.unselect(entity)
                    case .noSelect: self.select(entity)
                }
            default:
                fatalError()
        }
    }
    
    var logs: 💾Logs { .load(self.logsData) }
}

//MARK: private
private extension 📏MeasureModel {
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
        
        self.resetPosition_simulator()
        self.hideAndFadeIn()
    }
    
    private func hideAndFadeIn() {
        Task {
            let entities = [
                self.lineEntity,
                self.leftEntity,
                self.rightEntity,
                self.rootEntity.findEntity(named: "result")!
            ]
            entities.forEach { $0.isEnabled = false }
            try await Task.sleep(for: .seconds(3))
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
            💾Logs.current.add(self.createLog())
        }
    }
    
    private func createLog() -> 💾Log {
        let leftAnchor = WorldAnchor(originFromAnchorTransform: self.leftEntity.transform.matrix)
        let rightAnchor = WorldAnchor(originFromAnchorTransform: self.rightEntity.transform.matrix)
        let centerMatrix = Transform(translation: self.centerPosition).matrix
        let centerAnchor = WorldAnchor(originFromAnchorTransform: centerMatrix)
        let fixedLeftEntity = 🧩Entity.fixedPointer(leftAnchor)
        let fixedRightEntity = 🧩Entity.fixedPointer(rightAnchor)
        self.rootEntity.addChild(fixedLeftEntity)
        self.rootEntity.addChild(fixedRightEntity)
        self.rootEntity.addChild(🧩Entity.fixedCenter(centerAnchor))
        switch self.selection {
            case .left: fixedRightEntity.playAudio(self.sounds.fix)
            case .right: fixedLeftEntity.playAudio(self.sounds.fix)
            case .noSelect: fatalError()
        }
        return .init(leftID: leftAnchor.id,
                     rightID: rightAnchor.id,
                     centerID: centerAnchor.id,
                     lineLength: self.lineLength,
                     rotationRadians: self.rotation,
                     date: .now)
    }
    
    private func updateFixedLinesAndResults() {
        //placeholder
    }
}




//MARK: simulator
extension 📏MeasureModel {
    func setUp_simulator() {
#if targetEnvironment(simulator)
        self.updateLine()
        self.updateResult()
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
        self.updateResult()
#endif
    }
    private func resetPosition_simulator() {
#if targetEnvironment(simulator)
        self.leftEntity.position = .init(x: -0.2, y: 1.5, z: -0.7)
        self.rightEntity.position = .init(x: 0.2, y: 1.5, z: -0.7)
        self.updateLine()
        self.updateResult()
#endif
    }
}
