import SwiftUI
import RealityKit
import ARKit

struct 👆MeasureView: View {
    @EnvironmentObject var model: 📱AppModel
    var body: some View {
        RealityView { content, attachments in
            content.add(self.model.setupRootEntity())
            
            let resultLabelEntity = attachments.entity(for: Self.attachmentID)!
            resultLabelEntity.components.set(📍HeadAnchorComponent())
            resultLabelEntity.name = 🧩Name.resultLabel
            self.model.rootEntity.addChild(resultLabelEntity)
        } update: { _, attachments in
            attachments.entity(for: Self.attachmentID)!.position = self.model.resultLabelPosition
            
            self.model.fingerEntities[.left]?
                .components
                .set(🧩Model.fingerTip(self.model.selectedLeft))
            self.model.fingerEntities[.right]?
                .components
                .set(🧩Model.fingerTip(self.model.selectedRight))
        } attachments: {
            Attachment(id: Self.attachmentID) {
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
                        case 🧩Name.fingerLeft:
                            self.model.selectedLeft.toggle()
                        case 🧩Name.fingerRight:
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

fileprivate extension 👆MeasureView {
    private static let attachmentID: String = "resultLabel"
}
