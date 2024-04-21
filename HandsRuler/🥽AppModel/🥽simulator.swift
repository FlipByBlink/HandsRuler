extension 🥽AppModel {
    func setUp_simulator() {
#if targetEnvironment(simulator)
        self.updateRuler()
#endif
    }
    func setRandomPosition_simulator() {
#if targetEnvironment(simulator)
        if !self.selection.isLeft {
            self.entities.left.position = .init(x: .random(in: -0.8 ..< -0.05),
                                                y: .random(in: 1 ..< 1.5),
                                                z: .random(in: -1 ..< -0.5))
        }
        if !self.selection.isRight {
            self.entities.right.position = .init(x: .random(in: 0.05 ..< 0.8),
                                                 y: .random(in: 1 ..< 1.5),
                                                 z: .random(in: -1 ..< -0.5))
        }
        self.updateRuler()
#endif
    }
    func resetPosition_simulator() {
#if targetEnvironment(simulator)
        self.entities.left.position = 🧩Entity.Placeholder.leftPosition
        self.entities.right.position = 🧩Entity.Placeholder.rightPosition
        self.updateRuler()
#endif
    }
}
