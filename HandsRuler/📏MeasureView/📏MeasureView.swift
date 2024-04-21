import SwiftUI
import RealityKit
import ARKit

struct 📏MeasureView: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        RealityView { content, attachments in
            content.add(self.model.rootEntity)
            self.model.setUpChildEntities()
            
            let resultBoardEntity = attachments.entity(for: "resultBoard")!
            resultBoardEntity.components.set(🧑HeadTrackingComponent())
            resultBoardEntity.name = "resultBoard"
            self.model.rootEntity.addChild(resultBoardEntity)
            
            self.model.setUp_simulator()
//        } update: { _, attachments in
        } update: { _, _ in
//            self.model.logs.elements.forEach { log in //TODO: Work in progress
//                let fixedResultEntity = attachments.entity(for: "\(log.id)")!
//                fixedResultEntity.components.set(🪧FixedResultComponent(worldAnchorID: log.id))
//                self.model.rootEntity.addChild(fixedResultEntity)
//            }
        } attachments: {
            Attachment(id: "resultBoard") {
                📏ResultBoardView(self.model.resultValue)
            }
            ForEach(self.model.logs.elements) { log in
                Attachment(id: "\(log.id)") {
                    📏ResultBoardView(log.lineLength, log)
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { self.model.tap($0.entity) }
        )
        .task { self.model.run() }
        .onDisappear { self.model.openedImmersiveSpace = false }
    }
}
