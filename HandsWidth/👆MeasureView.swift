import SwiftUI
import RealityKit
import ARKit

struct 👆MeasureView: View {
    @EnvironmentObject var model: 📱AppModel
    var body: some View {
        RealityView { content, _ in
            content.add(self.model.setupRootEntity())
        } update: { _, attachments in
            guard let resultLabelEntity = attachments.entity(for: "resultLabel") else {
                assertionFailure(); return
            }
            resultLabelEntity.components.set(📍HeadAnchorComponent())
            resultLabelEntity.name = "\(🧩Entity.Name.resultLabel)"
            resultLabelEntity.position = self.model.resultLabelPosition
            self.model.rootEntity.addChild(resultLabelEntity)
        } attachments: {
            Attachment(id: "resultLabel") {
                Text(self.model.resultText)
                    .font(.system(size: 54).bold())
                    .padding(24)
                    .glassBackgroundEffect()
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded {
                    print("🖨️", Date.now.description, $0.entity.name)
                }
        )
        .task { await self.model.runSession() }
        .task { await self.model.processHandUpdates() }
    }
}
