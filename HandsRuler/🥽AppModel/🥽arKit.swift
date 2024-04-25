import ARKit

extension 🥽AppModel {
    func runARKitSession() async {
#if targetEnvironment(simulator)
        print("Not support ARKit tracking in simulator.")
#else
        do {
            try await self.arKitSession.run([self.handTrackingProvider,
                                             self.worldTrackingProvider])
        } catch {
            print(error)
        }
#endif
    }
    
    func processHandUpdates() async {
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
                    self.entities.left.setTransformMatrix(originFromIndex, relativeTo: nil)
                case .right:
                    self.entities.right.setTransformMatrix(originFromIndex, relativeTo: nil)
            }
            
            self.updateRuler()
        }
    }
    
    func processWorldAnchorUpdates() async {
        for await update in self.worldTrackingProvider.anchorUpdates {
            switch update.event {
                case .added:
                    self.activeWorldAnchors.append(update.anchor)
                    self.entities.setFixedRuler(self.logs, update.anchor)
                case .updated:
                    self.activeWorldAnchors.removeAll { $0.id == update.anchor.id }
                    self.activeWorldAnchors.append(update.anchor)
                    self.entities.updateFixedRuler(self.logs, update.anchor)
                case .removed:
                    self.activeWorldAnchors.removeAll { $0.id == update.anchor.id }
                    self.entities.removeFixedRuler(update.anchor.id)
            }
        }
    }
}
