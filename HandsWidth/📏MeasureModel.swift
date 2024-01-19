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
}

extension 📏MeasureModel {
    func setUpChildEntities() {
        self.rootEntity.addChild(self.lineEntity)
        self.fingerEntities.values.forEach { self.rootEntity.addChild($0) }
    }
    
    func updateFingerModel() {
        self.fingerEntities[.left]?.components.set(🧩Model.fingerTip(self.selectedLeft))
        self.fingerEntities[.right]?.components.set(🧩Model.fingerTip(self.selectedRight))
    }
    
    func changeSelection(_ targetedEntity: Entity) {
        switch targetedEntity.name {
            case 🧩Name.fingerLeft: self.selectedLeft.toggle()
            case 🧩Name.fingerRight: self.selectedRight.toggle()
            default: break
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
    
#if targetEnvironment(simulator)
    func setUp_simulator() {
        self.updateLine()
        self.updateResultLabelPosition()
    }
    func setRandomPosition_simulator() {
        if !self.selectedLeft {
            self.fingerEntities[.left]?.position = .init(x: -0.3,
                                                         y: .random(in: 1 ..< 2.0),
                                                         z: .random(in: -1.25 ..< -0.75))
        }
        if !self.selectedRight {
            self.fingerEntities[.right]?.position = .init(x: 0.3,
                                                          y: .random(in: 1 ..< 2.0),
                                                          z: .random(in: -1.25 ..< -0.75))
        }
        self.updateLine()
        self.updateResultLabelPosition()
    }
#endif
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
