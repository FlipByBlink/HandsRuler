import SwiftUI
import RealityKit
import ARKit

@MainActor
class 📏MeasureModel: ObservableObject {
    @AppStorage("unit") var unit: 📏Unit = .meters
    @Published var selectedLeft: Bool = false
    @Published var selectedRight: Bool = false
    
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()
    
    let rootEntity = Entity()
    let lineEntity = 🧩Entity.line()
    let fingerEntities: [HandAnchor.Chirality: Entity] = 🧩Entity.fingerTips()
}

extension 📏MeasureModel {
    func setUpChildEntities() {
        self.rootEntity.addChild(self.lineEntity)
        self.fingerEntities.values.forEach { self.rootEntity.addChild($0) }
        self.setUp_simulator()
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
        let measurement: Measurement = .init(value: .init(distance(self.leftPosition, self.rightPosition)),
                                             unit: UnitLength.meters)
        return formatter.string(from: measurement.converted(to: self.unit.value))
    }
    
    func runSession() async {
        do {
#if targetEnvironment(simulator)
            print("Not support handTracking in simulator.")
#else
            try await self.session.run([self.handTracking])
#endif
        } catch {
            assertionFailure()
        }
    }
    
    func processHandUpdates() async {
        for await update in self.handTracking.anchorUpdates {
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked,
                  let fingerTip = handAnchor.handSkeleton?.joint(.indexFingerTip),
                  fingerTip.isTracked else {
                continue
            }
            
            let originFromWrist = handAnchor.originFromAnchorTransform
            
            let wristFromIndex = fingerTip.anchorFromJointTransform
            let originFromIndex = originFromWrist * wristFromIndex
            self.fingerEntities[handAnchor.chirality]?.setTransformMatrix(originFromIndex,
                                                                          relativeTo: nil)
            
            self.updateLine()
        }
    }
    
    var centerPosition: SIMD3<Float> {
        (self.leftPosition + self.rightPosition) / 2
    }
}

fileprivate extension 📏MeasureModel {
    private func updateLine() {
        self.lineEntity.position = self.centerPosition
        self.lineEntity.components.set(🧩Model.line(self.leftPosition, self.rightPosition))
        self.lineEntity.look(at: self.leftPosition,
                             from: self.centerPosition,
                             relativeTo: nil)
    }
    
    private var leftPosition: SIMD3<Float> {
        self.fingerEntities[.left]?.position ?? .zero
    }
    
    private var rightPosition: SIMD3<Float> {
        self.fingerEntities[.right]?.position ?? .zero
    }
    
#if targetEnvironment(simulator)
    private func setUp_simulator() {
        self.updateLine()
    }
#endif
}
