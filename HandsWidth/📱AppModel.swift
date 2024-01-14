import SwiftUI
import RealityKit
import ARKit

@MainActor
class 📱AppModel: ObservableObject {
    @AppStorage("unit") var unit: 📏Unit = .meters
    @Published var presentImmersiveSpace: Bool = false
    @Published var presentSettingWindow: Bool = false
    @Published var resultText: String = ""
    
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()
    
    let rootEntity = Entity()
    let lineEntity = {
        let value = Entity()
        value.name = "line"
        value.components.set(OpacityComponent(opacity: 0.5))
        return value
    }()
    let indexTipEntities: [HandAnchor.Chirality: ModelEntity] = {
        return [.left: ModelEntity(mesh: .generateSphere(radius: 0.01),
                                   materials: [SimpleMaterial(color: .blue, isMetallic: false)]),
                .right: ModelEntity(mesh: .generateSphere(radius: 0.01),
                                    materials: [SimpleMaterial(color: .red, isMetallic: false)])]
    }()
}

extension 📱AppModel {
    func setupRootEntity() -> Entity {
        self.indexTipEntities.values.forEach {
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
                  let indexTip = handAnchor.handSkeleton?.joint(.indexFingerTip),
                  indexTip.isTracked else {
                continue
            }
            
            let originFromWrist = handAnchor.originFromAnchorTransform
            
            let wristFromIndex = indexTip.anchorFromJointTransform
            let originFromIndex = originFromWrist * wristFromIndex
            indexTipEntities[handAnchor.chirality]?.setTransformMatrix(originFromIndex,
                                                                       relativeTo: nil)
            
            self.updateResultLabel()
            self.updateLine()
        }
    }
    
    var resultLabelPosition: SIMD3<Float> {
        self.indexTipEntities.values.reduce(into: .zero) { $0 += $1.position } / 2
    }
}

fileprivate extension 📱AppModel {
    private func updateResultLabel() {
        guard let leftPosition = self.indexTipEntities[.left]?.position,
              let rightPosition = self.indexTipEntities[.right]?.position else {
            assertionFailure(); return
        }
        let formatter = LengthFormatter()
        formatter.numberFormatter.maximumFractionDigits = 2
        self.resultText = formatter.string(fromValue: .init(distance(leftPosition, rightPosition)),
                                           unit: self.unit.formatterValue)
    }
    private func updateLine() {
        guard let leftPosition = self.indexTipEntities[.left]?.position,
              let rightPosition = self.indexTipEntities[.right]?.position else {
            assertionFailure(); return
        }
        self.lineEntity.position = (leftPosition + rightPosition) / 2
        self.lineEntity.components.set(
            ModelComponent(mesh: .generateBox(width: 0.01,
                                              height: 0.01,
                                              depth: distance(leftPosition, rightPosition),
                                              cornerRadius: 0.005),
                           materials: [SimpleMaterial(color: .white, isMetallic: false)])
        )
        self.lineEntity.look(at: leftPosition,
                             from: self.lineEntity.position,
                             relativeTo: nil)
        self.lineEntity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.08),
                                             materials: [OcclusionMaterial()]))
    }
}

fileprivate extension 📱AppModel {
#if targetEnvironment(simulator)
    func setUp_simulator() {
        self.indexTipEntities[.left]?.position = .init(x: -0.3, y: 1.5, z: -1)
        self.indexTipEntities[.right]?.position = .init(x: 0.3, y: 1.5, z: -1)
        
        self.updateResultLabel()
        self.updateLine()
    }
#endif
}
