import SwiftUI
import RealityKit
import ARKit

struct 👆MeasureView: View {
    @EnvironmentObject var model: 📱AppModel
    var body: some View {
        RealityView { content, _ in
            content.add(self.model.setupRootEntity())
        } update: { content, attachments in
            guard let resultLabelEntity = attachments.entity(for: "resultLabel") else {
                assertionFailure()
                return
            }
            resultLabelEntity.components.set(📍AnchorComponent())
            resultLabelEntity.name = "resultLabel"
            resultLabelEntity.position = self.model.resultLabelPosition
            self.model.rootEntity.addChild(resultLabelEntity)
        } attachments: {
            Attachment(id: "resultLabel") {
                Text("placeholder")
                    .font(.system(size: 54).bold())
                    .padding(24)
                    .glassBackgroundEffect()
            }
        }
        .onTapGesture {}
        .task { await self.model.runSession() }
        .task { await self.model.processHandUpdates() }
    }
}
