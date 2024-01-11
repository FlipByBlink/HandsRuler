import RealityKit
import ARKit
import SwiftUI

struct 📍HeadAnchorComponent: Component, Codable {
    init() {}
}

struct 📍HeadAnchorSystem: System {
    private let session = ARKitSession()
    private let provider = WorldTrackingProvider()
    
    init(scene: RealityKit.Scene) {
        self.setUpSession()
    }
    
    private func setUpSession() {
        Task {
            do {
                try await self.session.run([self.provider])
            } catch {
                assertionFailure()
            }
        }
    }
    
    func update(context: SceneUpdateContext) {
        guard let deviceAnchor = self.provider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else {
            return
        }
        for entity in context.entities(matching: .init(where: .has(📍HeadAnchorComponent.self)), 
                                       updatingSystemWhen: .rendering) {
            if entity.name == "resultLabel" {
                entity.look(at: Transform(matrix: deviceAnchor.originFromAnchorTransform).translation,
                            from: entity.position(relativeTo: nil),
                            relativeTo: nil,
                            forward: .positiveZ)
            }
#if DEBUG
            if entity.name == "POINTER" {
                entity.transform = Transform(matrix: deviceAnchor.originFromAnchorTransform)
                entity.setPosition([0, 0, -1], relativeTo: entity)
            }
#endif
        }
    }
}
