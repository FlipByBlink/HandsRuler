import SwiftUI
import RealityKit
import ARKit

@MainActor
class 📱AppModel: ObservableObject {
    @AppStorage("unit") var unit: 📏Unit = .meters
    @AppStorage("mode") var mode: 🪄Mode = .handToHand
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
        [.left: ModelEntity(mesh: .generateSphere(radius: 0.01),
                            materials: [SimpleMaterial(color: .blue, isMetallic: false)]),
         .right: ModelEntity(mesh: .generateSphere(radius: 0.01),
                             materials: [SimpleMaterial(color: .red, isMetallic: false)])]
    }()
    let heightLineEntity = Entity()
    let groundPointEntity: Entity = {
        let radius: Float = 0.03
        let value = ModelEntity(mesh: .generateSphere(radius: radius),
                                materials: [SimpleMaterial(color: .yellow, isMetallic: false)])
        let occlusion = ModelEntity(mesh: .generateCylinder(height: radius, radius: radius),
                                    materials: [OcclusionMaterial()])
        occlusion.position.y -= radius / 2
        value.addChild(occlusion)
        return value
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
        self.rootEntity.addChild(self.groundPointEntity)
        self.rootEntity.addChild(self.heightLineEntity)
        
        self.indexTipEntities[.left]?.position = .init(x: -0.3, y: 1.5, z: -1)
        self.indexTipEntities[.right]?.position = .init(x: 0.3, y: 1.5, z: -1)
        self.groundPointEntity.position = .init(x: 0.3, y: 0, z: -1)
        
        self.updateResultLabel()
        self.updateLine()
        
        guard let rightPosition = self.indexTipEntities[.right]?.position else {
            assertionFailure(); return
        }
        self.heightLineEntity.position = (self.groundPointEntity.position + rightPosition) / 2
        self.heightLineEntity.components.set(
            ModelComponent(mesh: .generateBox(width: 0.01,
                                              height: 0.01,
                                              depth: distance(self.groundPointEntity.position, rightPosition),
                                              cornerRadius: 0.005),
                           materials: [SimpleMaterial(color: .white, isMetallic: false)])
        )
        self.heightLineEntity.look(at: self.groundPointEntity.position,
                                   from: self.heightLineEntity.position,
                                   relativeTo: nil)
        self.heightLineEntity.addChild(ModelEntity(mesh: .generateSphere(radius: 0.08),
                                                   materials: [OcclusionMaterial()]))
    }
#endif
}
