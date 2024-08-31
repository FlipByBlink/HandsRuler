import ARKit
import RealityKit

extension 🥽AppModel {
    func runARKitSession() async {
#if targetEnvironment(simulator)
        print("Not support ARKit tracking in simulator.")
#else
        do {
            try await self.arKitSession.run([self.handTrackingProvider,
                                             self.worldTrackingProvider,
                                             self.sceneReconstructionProvider])
        } catch {
            print(error)
        }
#endif
    }
    
    func processHandUpdates() async {
        for await update in self.handTrackingProvider.anchorUpdates {
            let handAnchor = update.anchor
            
            self.processRestoreAction(handAnchor)
            if self.isSelected(handAnchor) { continue }
            
            switch self.mode {
                case .normal:
                    self.updateFingerTipPosition(handAnchor)
                    self.entities.updateLineAndResultBoard()
                case .raycast:
                    switch handAnchor.chirality {
                        case .right:
                            self.updateFingerTipPosition(handAnchor)
                        case .left:
                            self.updateRaycastedPointer()
                    }
                    self.entities.updateLineAndResultBoard()
            }
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
    
    func processSceneUpdates() async {
        for await update in self.sceneReconstructionProvider.anchorUpdates {
            let meshAnchor = update.anchor
            
            guard let shape = try? await ShapeResource.generateStaticMesh(from: meshAnchor) else {
                continue
            }
            
            switch update.event {
                case .added:
                    let entity = Entity()
                    entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                    entity.components.set(CollisionComponent(shapes: [shape],
                                                             isStatic: true))
                    self.entities.surrounding[meshAnchor.id] = entity
                    self.entities.root.addChild(entity)
                case .updated:
                    guard let entity = self.entities.surrounding[meshAnchor.id] else { return }
                    entity.transform = Transform(matrix: meshAnchor.originFromAnchorTransform)
                    entity.components[CollisionComponent.self]?.shapes = [shape]
                case .removed:
                    self.entities.surrounding[meshAnchor.id]?.removeFromParent()
                    self.entities.surrounding.removeValue(forKey: meshAnchor.id)
            }
        }
    }
}
