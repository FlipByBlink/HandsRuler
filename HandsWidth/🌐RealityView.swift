import SwiftUI
import RealityKit
import ARKit

struct 🌐RealityView: View {
    @EnvironmentObject var model: 📱AppModel
    @StateObject var measureModel: 📏MeasureModel = .init()
    var body: some View {
        RealityView { content, attachments in
            content.add(self.measureModel.rootEntity)
            self.measureModel.setUpChildEntities()
            
            let resultLabelEntity = attachments.entity(for: Self.attachmentID)!
            resultLabelEntity.components.set(🧑HeadTrackingComponent())
            resultLabelEntity.name = 🧩Name.resultLabel
            self.measureModel.rootEntity.addChild(resultLabelEntity)
            
            self.measureModel.setUp_simulator()
        } update: { _, attachments in
            self.measureModel.updateFingerModel()
        } attachments: {
            Attachment(id: Self.attachmentID) {
                TimelineView(.periodic(from: .now, by: 0.2)) { _ in
                    Text(self.measureModel.resultText)
                        .font(.system(size: 54).bold())
                        .padding(24)
                        .glassBackgroundEffect()
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { self.measureModel.changeSelection($0.entity) }
        )
        .task {
            await self.measureModel.runSession()
            await self.measureModel.processHandUpdates()
        }
    }
    static let attachmentID: String = "resultLabel"
}
