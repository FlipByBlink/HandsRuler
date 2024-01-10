import SwiftUI
import RealityKit
import ARKit

class 📱AppModel: ObservableObject {
    @AppStorage("unit") var unit: 📏Unit = .meters
    @Published var presentImmersiveSpace: Bool = false
    @Published var presentSettingWindow: Bool = false
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()
    var rootEntity = Entity()
    let fingerEntities: [HandAnchor.Chirality: ModelEntity] = [
        .left: createFingertip,
        .right: createFingertip
    ]
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
            print(#function, error)
            assertionFailure()
        }
    }
    
    func processHandUpdates() async {
        for await update in handTracking.anchorUpdates {
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
                .setTransformMatrix(originFromIndex,
                                    relativeTo: nil)
        }
    }
    
    var resultLabelPosition: SIMD3<Float> {
        self.fingerEntities.values.reduce(into: .zero) { $0 += $1.position }
        /
        2
    }
}

fileprivate extension 📱AppModel {
    static var createFingertip: ModelEntity {
        .init(mesh: .generateSphere(radius: 0.05),
              materials: [SimpleMaterial(color: .white, isMetallic: false)])
    }
}
