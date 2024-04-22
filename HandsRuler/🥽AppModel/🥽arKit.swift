import ARKit

extension 🥽AppModel {
    func runARKitSession() {
#if targetEnvironment(simulator)
        print("Not support ARKit tracking in simulator.")
#else
        Task { @MainActor in
            do {
                try await self.arKitSession.runARKitSession([self.handTrackingProvider,
                                                             self.worldTrackingProvider])
                Task { await self.processHandUpdates() }
                Task { await self.processWorldAnchorUpdates() }
            } catch {
                print(error)
            }
        }
#endif
    }
}

private extension 🥽AppModel {
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
                    self.entities.left.setTransformMatrix(originFromIndex, relativeTo: nil)
                case .right:
                    self.entities.right.setTransformMatrix(originFromIndex, relativeTo: nil)
            }
            
            self.updateRuler()
        }
    }
    
    private func processWorldAnchorUpdates() async {
        for await update in self.worldTrackingProvider.anchorUpdates {
            switch update.event {
                case .added:
                    self.activeFixedRulerAnchorIDs.append(update.anchor.id)
                    self.entities.setFixedRuler(logs, update.anchor)
                case .updated:
                    self.entities.updateFixedRuler(logs, update.anchor)
                case .removed:
                    self.activeFixedRulerAnchorIDs.removeAll { $0 == update.anchor.id }
                    self.entities.removeFixedRuler(logs, update.anchor)
            }
        }
    }
}
