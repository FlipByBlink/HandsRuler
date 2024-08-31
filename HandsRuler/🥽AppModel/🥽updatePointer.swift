import ARKit
import RealityKit

extension 🥽AppModel {
    func updateFingerTipPosition(_ handAnchor: HandAnchor) {
        guard handAnchor.isTracked,
              let fingerTip = handAnchor.handSkeleton?.joint(.indexFingerTip),
              fingerTip.isTracked else {
            return
        }
        
        let originFromWrist = handAnchor.originFromAnchorTransform
        let wristFromIndex = fingerTip.anchorFromJointTransform
        let originFromIndex = originFromWrist * wristFromIndex
        
        switch handAnchor.chirality {
            case .right:
                self.entities.right.setTransformMatrix(originFromIndex,
                                                       relativeTo: nil)
            case .left:
                self.entities.left.setTransformMatrix(originFromIndex,
                                                      relativeTo: nil)
        }
    }
    
    func updateRaycastedPointer() {
        guard !self.selection.isLeft,
              let hit = self.entities.raycast() else {
            return
        }
        
        self.currentHits.append(hit.position)
        if self.currentHits.count > 10 { self.currentHits.removeFirst() }
        
        self.entities.left.position
        =
        self.currentHits.reduce(.zero, +) / Float(self.currentHits.count)
    }
}
