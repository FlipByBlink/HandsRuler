import SwiftUI
import RealityKit
import ARKit

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
        value.components.set(OpacityComponent(opacity: 0.9))
        return value
    }()
    let fingerEntities: [HandAnchor.Chirality: ModelEntity] = {
        let entity = ModelEntity(mesh: .generateSphere(radius: 0.05),
                                 materials: [SimpleMaterial(color: .white, isMetallic: false)])
        return [.left: entity, .right: entity]
    }()
}

extension 📱AppModel {
    func setupRootEntity() -> Entity {
        self.fingerEntities.values.forEach {
            self.rootEntity.addChild($0)
        }
        return self.rootEntity
    }
    
    func runSession() async {
        do {
            try await self.session.run([self.handTracking])
        } catch {
            assertionFailure()
        }
    }
    
    func processHandUpdates() async {
        for await update in self.handTracking.anchorUpdates {
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked,
                  let fingertip = handAnchor.handSkeleton?.joint(.indexFingerTip),
                  fingertip.isTracked else {
                continue
            }
            
            let originFromWrist = handAnchor.originFromAnchorTransform
            let wristFromIndex = fingertip.anchorFromJointTransform
            let originFromIndex = originFromWrist * wristFromIndex
            
            await fingerEntities[handAnchor.chirality]?
                .setTransformMatrix(originFromIndex, relativeTo: nil)
            
            self.updateResultLabel()
            self.updateLine()
        }
    }
    
    var resultLabelPosition: SIMD3<Float> {
        self.fingerEntities.values.reduce(into: .zero) { $0 += $1.position } / 2
    }
}

fileprivate extension 📱AppModel {
    private func updateResultLabel() {
        guard let leftPosition = self.fingerEntities[.left]?.position,
              let rightPosition = self.fingerEntities[.right]?.position else {
            assertionFailure(); return
        }
        let formatter = LengthFormatter()
        formatter.numberFormatter.maximumFractionDigits = 2
        self.resultText = formatter.string(fromValue: .init(distance(leftPosition, rightPosition)),
                                           unit: self.unit.formatterValue)
    }
    private func updateLine() {
        guard let leftPosition = self.fingerEntities[.left]?.position,
              let rightPosition = self.fingerEntities[.right]?.position else {
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
