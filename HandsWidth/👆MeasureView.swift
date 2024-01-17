import SwiftUI
import RealityKit
import ARKit

struct 👆MeasureView: View {
    @EnvironmentObject var model: 📱AppModel
    var body: some View {
        RealityView { content, attachments in
            content.add(self.model.setupRootEntity())
            
            let resultLabelEntity = attachments.entity(for: "resultLabel")!
            resultLabelEntity.components.set(📍HeadAnchorComponent())
            resultLabelEntity.name = 🧩Name.resultLabel
            self.model.rootEntity.addChild(resultLabelEntity)
        } update: { _, attachments in
            attachments.entity(for: "resultLabel")!.position = self.model.resultLabelPosition
            
            self.model.fingerTipEntities[.left]?
                .components
                .set(🧩Model.fingerTip(self.model.selectedLeft))
            self.model.fingerTipEntities[.right]?
                .components
                .set(🧩Model.fingerTip(self.model.selectedRight))
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
                    switch $0.entity.name {
                        case 🧩Name.fingerTipLeft:
                            self.model.selectedLeft.toggle()
                        case 🧩Name.fingerTipRight:
                            self.model.selectedRight.toggle()
                        default:
                            break
                    }
                }
        )
        .task { await self.model.runSession() }
        .task { await self.model.processHandUpdates() }
    }
}
