import RealityKit
import ARKit
import SwiftUI

struct 📍AnchorComponent: Component, Codable {
    init() {}
}

struct 📍AnchorSystem: System {
    private let arkitSession = ARKitSession()
    private let worldTrackingProvider = WorldTrackingProvider()
    
    init(scene: RealityKit.Scene) {
        self.setUpSession()
    }
    
    func setUpSession() {
        Task { try! await self.arkitSession.run([self.worldTrackingProvider]) }
    }
    
    func update(context: SceneUpdateContext) {
        guard let deviceAnchor = self.worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) else {
            return
        }
        for entity in context.entities(matching: .init(where: .has(📍AnchorComponent.self)), updatingSystemWhen: .rendering) {
            if entity.name == "POINTER" {
                entity.transform = Transform(matrix: deviceAnchor.originFromAnchorTransform)
                entity.setPosition([0, 0, -1], relativeTo: entity)
            }
            if entity.name == "AttachmentName" {
                entity.look(at: Transform(matrix: deviceAnchor.originFromAnchorTransform).translation,
                            from: entity.position(relativeTo: nil),
                            relativeTo: nil,
                            forward: .positiveZ)
            }
        }
    }
}
