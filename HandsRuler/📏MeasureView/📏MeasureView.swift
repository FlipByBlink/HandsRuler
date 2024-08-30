import SwiftUI
import RealityKit
import ARKit

struct 📏MeasureView: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        RealityView { content, attachments in
            content.add(self.model.entities.root)
            self.model.entities.setUpChildren()
            
            let resultBoardEntity = attachments.entity(for: "resultBoard")!
            resultBoardEntity.components.set(🪧BillboardComponent())
            resultBoardEntity.name = "resultBoard"
            self.model.entities.add(resultBoardEntity)
            
            self.model.setUp_simulator()
        } update: { _, attachments in
            for worldAnchor in self.model.activeWorldAnchors {
                guard let fixedResultBoardEntity = attachments.entity(for: "\(worldAnchor.id)"),
                      let log = self.model.logs[worldAnchor.id] else {
                    continue
                }
                fixedResultBoardEntity.components.set(🪧BillboardComponent())
                fixedResultBoardEntity.setTransformMatrix(worldAnchor.originFromAnchorTransform,
                                                          relativeTo: nil)
                fixedResultBoardEntity.setPosition(log.centerPosition,
                                                   relativeTo: fixedResultBoardEntity)
                self.model.entities.add(fixedResultBoardEntity)
            }
        } attachments: {
            Attachment(id: "resultBoard") {
                📏ResultBoardView()
            }
            ForEach(self.model.activeWorldAnchors, id: \.id) { worldAnchor in
                Attachment(id: "\(worldAnchor.id)") {
                    📏ResultBoardViewForFixedRuler(worldAnchor.id)
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { self.model.tap($0.entity) }
        )
        .task { await self.model.runARKitSession() }
        .task { await self.model.processHandUpdates() }
        .task { await self.model.processWorldAnchorUpdates() }
        .onDisappear {
            self.model.clearSelection()
            self.model.openedImmersiveSpace = false
        }
    }
}
