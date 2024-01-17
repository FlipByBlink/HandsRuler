import SwiftUI
import RealityKit
import ARKit

@MainActor
class 📱AppModel: ObservableObject {
    @AppStorage("unit") var unit: 📏Unit = .meters
    @Published var presentImmersiveSpace: Bool = false
    @Published var presentSettingWindow: Bool = false
    @Published var resultText: String = ""
    @Published var selectedLeft: Bool = false
    @Published var selectedRight: Bool = false
    
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()
    
    let rootEntity = Entity()
    let lineEntity = 🧩Entity.line()
    let fingerEntities: [HandAnchor.Chirality: Entity] = 🧩Entity.fingerTips()
}

extension 📱AppModel {
    func setupRootEntity() -> Entity {
        self.fingerEntities.values.forEach {
            self.rootEntity.addChild($0)
        }
        self.rootEntity.addChild(self.lineEntity)
        self.setUp_simulator()
        return self.rootEntity
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
            
            self.updateResultLabel()
            self.updateLine()
        }
    }
    
    var resultLabelPosition: SIMD3<Float> {
        self.fingerEntities.values.reduce(into: .zero) { $0 += $1.position } / 2
    }
    
    func updateResultLabel() {
        guard let leftPosition = self.fingerEntities[.left]?.position,
              let rightPosition = self.fingerEntities[.right]?.position else {
            assertionFailure(); return
        }
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 2
        let measurement: Measurement = .init(value: .init(distance(leftPosition, rightPosition)),
                                             unit: UnitLength.meters)
        self.resultText = formatter.string(from: measurement.converted(to: self.unit.value))
    }
}

fileprivate extension 📱AppModel {
    private func updateLine() {
        guard let leftPosition = self.fingerEntities[.left]?.position,
              let rightPosition = self.fingerEntities[.right]?.position else {
            assertionFailure(); return
        }
        self.lineEntity.position = (leftPosition + rightPosition) / 2
        self.lineEntity.components.set(🧩Model.line(leftPosition, rightPosition))
        self.lineEntity.look(at: leftPosition,
                             from: self.lineEntity.position,
                             relativeTo: nil)
    }
}

fileprivate extension 📱AppModel {
#if targetEnvironment(simulator)
    func setUp_simulator() {
        self.updateResultLabel()
        self.updateLine()
    }
#endif
}
