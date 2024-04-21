import SwiftUI

extension 🥽AppModel {
    func updateRuler() {
        self.entities.updateRuler()
        self.resultValue = distance(self.entities.left.position, self.entities.right.position)
    }
}
