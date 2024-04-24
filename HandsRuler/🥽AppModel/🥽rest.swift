extension 🥽AppModel {
    func clearSelection() {
        self.selection = .noSelect
        self.entities.left.components.set(🧩Model.fingerTip(.blue))
        self.entities.right.components.set(🧩Model.fingerTip(.blue))
    }
}
