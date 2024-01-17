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
                assertionFailure(); return
            }
            resultLabelEntity.components.set(📍HeadAnchorComponent())
            resultLabelEntity.name = 🧩Entity.Name.resultLabel
            resultLabelEntity.position = self.model.resultLabelPosition
            self.model.rootEntity.addChild(resultLabelEntity)
            
            self.model.fingerTipEntities[.left]?
                .components.set(🧩Entity.fingerTipModel(self.model.selectedLeft))
            self.model.fingerTipEntities[.right]?
                .components.set(🧩Entity.fingerTipModel(self.model.selectedRight))
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
                        case 🧩Entity.Name.fingerTipLeft:
                            self.model.selectedLeft.toggle()
                        case 🧩Entity.Name.fingerTipRight:
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
