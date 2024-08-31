import ARKit
import RealityKit

extension 🥽AppModel {
    func isSelected(_ handAnchor: HandAnchor) -> Bool {
        switch handAnchor.chirality {
            case .left: self.selection.isLeft
            case .right: self.selection.isRight
        }
    }
    
    func setCooldownState() {
        Task {
            self.isCooldownActive = true
            try? await Task.sleep(for: .seconds(2.5))
            self.isCooldownActive = false
        }
    }
    
    func processRestoreAction(_ handAnchor: HandAnchor) {
        guard !self.isCooldownActive else { return }
        
        guard let fingerTip = handAnchor.handSkeleton?.joint(.indexFingerTip) else {
            assertionFailure()
            return
        }
        
        guard self.selection != .noSelect else { return }
        
        if self.selection.isLeft, handAnchor.chirality == .right { return }
        if self.selection.isRight, handAnchor.chirality == .left { return }
        
        let originFromWrist = handAnchor.originFromAnchorTransform
        let wristFromIndex = fingerTip.anchorFromJointTransform
        let originFromIndex = originFromWrist * wristFromIndex
        let handAnchorPosition = Transform(matrix: originFromIndex).translation
        
        let entity = {
            switch handAnchor.chirality {
                case .left: self.entities.left
                case .right: self.entities.right
            }
        }()
        
        if distance(entity.position, handAnchorPosition) < 0.01 {
            self.unselect(entity)
        }
    }
    
    func clearSelection() {
        self.selection = .noSelect
        self.entities.left.components.set(🧩Model.fingerTip(.blue))
        self.entities.right.components.set(🧩Model.fingerTip(.blue))
    }
}
