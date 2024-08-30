import ARKit
import RealityKit

extension 🥽AppModel {
    func isSelected(_ handAnchor: HandAnchor) -> Bool {
        switch handAnchor.chirality {
            case .left:
                return self.selection == .left
            case .right:
                return self.selection == .right
        }
    }
    
    func setCooldownState() {
        self.isCooldownActive = true
        Task {
            try? await Task.sleep(for: .seconds(1.5))
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
        
        if self.selection == .left, handAnchor.chirality == .right { return }
        if self.selection == .right, handAnchor.chirality == .left { return }
        
        let originFromWrist = handAnchor.originFromAnchorTransform
        let wristFromIndex = fingerTip.anchorFromJointTransform
        let originFromIndex = originFromWrist * wristFromIndex
        
        let entity = {
            switch handAnchor.chirality {
                case .left: self.entities.left
                case .right: self.entities.right
            }
        }()
        
        if distance(entity.position, Transform(matrix: originFromIndex).translation) < 0.01 {
            self.selection = .noSelect
            entity.components.set(🧩Model.fingerTip(.blue))
            entity.playAudio(self.sounds.unselect)
        }
    }
    
    func clearSelection() {
        self.selection = .noSelect
        self.entities.left.components.set(🧩Model.fingerTip(.blue))
        self.entities.right.components.set(🧩Model.fingerTip(.blue))
    }
}
