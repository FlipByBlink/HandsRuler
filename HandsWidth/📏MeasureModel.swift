import SwiftUI
import RealityKit
import ARKit

@MainActor
class 📏MeasureModel: ObservableObject {
    @AppStorage("unit") private var unit: 📏Unit = .meters
    @Published var selectedLeft: Bool = false
    @Published var selectedRight: Bool = false
    
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()
    
    let rootEntity = Entity()
    private let lineEntity = 🧩Entity.line()
    private let fingerEntities: [HandAnchor.Chirality: Entity] = 🧩Entity.fingerTips()
    
    private let sound1: AudioFileResource = try! .load(named: "sound1")
    private let sound2: AudioFileResource = try! .load(named: "sound2")
    
    private var coolDownSelection: Bool = false
}

extension 📏MeasureModel {
    func setUpChildEntities() {
        self.rootEntity.addChild(self.lineEntity)
        self.fingerEntities.values.forEach { self.rootEntity.addChild($0) }
    }
    
    func changeSelection(_ targetedEntity: Entity) {
        guard !self.coolDownSelection else { return }
        self.coolDownSelection = true
        switch targetedEntity.name {
            case 🧩Name.fingerLeft: 
                self.selectedLeft.toggle()
                self.fingerEntities[.left]?.components.set(🧩Model.fingerTip(self.selectedLeft))
                targetedEntity.playAudio(self.selectedLeft ? self.sound1 : self.sound2)
            case 🧩Name.fingerRight:
                self.selectedRight.toggle()
                self.fingerEntities[.right]?.components.set(🧩Model.fingerTip(self.selectedRight))
                targetedEntity.playAudio(self.selectedRight ? self.sound1 : self.sound2)
            default:
                assertionFailure()
                break
        }
        Task {
            try? await Task.sleep(for: .seconds(1))
            self.coolDownSelection = false
        }
    }
    
    var resultText: String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 2
        let measurement = Measurement(value: .init(self.lineLength),
                                      unit: UnitLength.meters)
        return formatter.string(from: measurement.converted(to: self.unit.value))
    }
    
    var labelFontSize: Double {
        self.lineLength < 1.2 ? 24 : 42
    }
    
    func runSession() async {
        do {
#if targetEnvironment(simulator)
            print("Not support handTracking in simulator.")
#else
            try await self.session.run([self.handTracking])
            await self.processHandUpdates()
#endif
        } catch {
            assertionFailure()
        }
    }
}

fileprivate extension 📏MeasureModel {
    private func processHandUpdates() async {
        for await update in self.handTracking.anchorUpdates {
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
            self.fingerEntities[handAnchor.chirality]?.setTransformMatrix(originFromIndex,
                                                                          relativeTo: nil)
            
            self.updateLine()
            self.updateResultLabelPosition()
        }
    }
    
    private func updateLine() {
        self.lineEntity.position = self.centerPosition
        self.lineEntity.components.set(🧩Model.line(self.lineLength))
        self.lineEntity.look(at: self.leftPosition,
                             from: self.centerPosition,
                             relativeTo: nil)
    }
    
    private func updateResultLabelPosition() {
        self.rootEntity.findEntity(named: 🌐RealityView.attachmentID)?
            .position = self.centerPosition
    }
    
    private var lineLength: Float {
        distance(self.leftPosition, self.rightPosition)
    }
    
    private var centerPosition: SIMD3<Float> {
        (self.leftPosition + self.rightPosition) / 2
    }
    
    private var leftPosition: SIMD3<Float> {
        self.fingerEntities[.left]?.position ?? .zero
    }
    
    private var rightPosition: SIMD3<Float> {
        self.fingerEntities[.right]?.position ?? .zero
    }
}




//MARK: Simulator
extension 📏MeasureModel {
    func setUp_simulator() {
#if targetEnvironment(simulator)
        self.updateLine()
        self.updateResultLabelPosition()
#endif
    }
    func setRandomPosition_simulator() {
#if targetEnvironment(simulator)
        if !self.selectedLeft {
            self.fingerEntities[.left]?.position = .init(x: .random(in: -0.8 ..< -0.05),
                                                         y: .random(in: 1 ..< 1.5),
                                                         z: .random(in: -1 ..< -0.5))
        }
        if !self.selectedRight {
            self.fingerEntities[.right]?.position = .init(x: .random(in: 0.05 ..< 0.8),
                                                          y: .random(in: 1 ..< 1.5),
                                                          z: .random(in: -1 ..< -0.5))
        }
        self.updateLine()
        self.updateResultLabelPosition()
#endif
    }
}
