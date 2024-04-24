import ARKit
import RealityKit

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
    func setPlaceholder1FixedRuler_simulator() {
#if targetEnvironment(simulator)
        Task {
            try? await Task.sleep(for: .seconds(1))
            let worldAnchor = WorldAnchor(originFromAnchorTransform: Transform().matrix)
            self.logs.add(💾Log(worldAnchorID: worldAnchor.id,
                                leftPosition: .init(x: 0.24, y: 1.3, z: -1),
                                rightPosition: .init(x: -0.25, y: 1.43, z: -0.9),
                                date: .now))
            self.activeWorldAnchors.append(worldAnchor)
            self.entities.setFixedRuler(self.logs, worldAnchor)
        }
#endif
    }
    func setPlaceholderFixedRulers_simulator() {
#if targetEnvironment(simulator)
        Task {
            try? await Task.sleep(for: .seconds(1))
            do {
                let worldAnchor = WorldAnchor(originFromAnchorTransform: Transform().matrix)
                self.logs.add(💾Log(worldAnchorID: worldAnchor.id,
                                    leftPosition: .init(x: 0.74, y: 0.7, z: -1.4),
                                    rightPosition: .init(x: -0.65, y: 0.7, z: -1.4),
                                    date: .now))
                self.activeWorldAnchors.append(worldAnchor)
                self.entities.setFixedRuler(self.logs, worldAnchor)
            }
            do {
                let worldAnchor = WorldAnchor(originFromAnchorTransform: Transform().matrix)
                self.logs.add(💾Log(worldAnchorID: worldAnchor.id,
                                    leftPosition: .init(x: 0.745, y: 0.71, z: -1.4),
                                    rightPosition: .init(x: 0.745, y: 0.7, z: -1.85),
                                    date: .now))
                self.activeWorldAnchors.append(worldAnchor)
                self.entities.setFixedRuler(self.logs, worldAnchor)
            }
            do {
                let worldAnchor = WorldAnchor(originFromAnchorTransform: Transform().matrix)
                self.logs.add(💾Log(worldAnchorID: worldAnchor.id,
                                    leftPosition: .init(x: 0.74, y: 0, z: -1.4),
                                    rightPosition: .init(x: 0.745, y: 0.685, z: -1.4),
                                    date: .now))
                self.activeWorldAnchors.append(worldAnchor)
                self.entities.setFixedRuler(self.logs, worldAnchor)
            }
        }
#endif
    }
}
