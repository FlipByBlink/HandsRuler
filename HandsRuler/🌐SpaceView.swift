import SwiftUI
import RealityKit
import ARKit

struct 🌐SpaceView: View {
    @EnvironmentObject var appModel: 🥽AppModel
    @StateObject private var spaceModel: 🌐SpaceModel = .init()
    var body: some View {
        RealityView { content, attachments in
            content.add(self.spaceModel.rootEntity)
            self.spaceModel.setUpChildEntities()
            
            let resultLabelEntity = attachments.entity(for: Self.attachmentID)!
            resultLabelEntity.components.set(🧑HeadTrackingComponent())
            resultLabelEntity.name = 🧩Name.resultLabel
            self.spaceModel.rootEntity.addChild(resultLabelEntity)
            
            self.spaceModel.setUp_simulator()
        } update: { _, attachments in
            self.spaceModel.logs.elements.forEach { log in
                let resultLabelEntity = attachments.entity(for: "\(log.id)")!
                resultLabelEntity.components.set(🧑HeadTrackingComponent())
                resultLabelEntity.name = "\(log.id)"
                self.spaceModel.rootEntity.addChild(resultLabelEntity)
            }
        } attachments: {
            Attachment(id: Self.attachmentID) {
                self.resultLabelView(self.spaceModel.resultText, self.spaceModel.labelFontSize)
            }
            ForEach(self.spaceModel.logs.elements) {
                Attachment(id: "\($0.id)") {
                    self.resultLabelView("placeholder", 30)
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { self.spaceModel.changeSelection($0.entity) }
        )
        .task { self.spaceModel.run() }
        .onAppear { self.appModel.openedImmersiveSpace = true }
        .onDisappear { self.appModel.openedImmersiveSpace = false }
    }
    static let attachmentID: String = "resultLabel"
}

private extension 🌐SpaceView {
    private func resultLabelView(_ text: String, _ size: Double) -> some View {
        TimelineView(.periodic(from: .now, by: 0.2)) { _ in
            Text(text)
                .font(.system(size: size))
                .fontWeight(.bold)
                .monospacedDigit()
                .padding(12)
                .padding(.horizontal, 4)
                .glassBackgroundEffect()
                .modifier(Self.SetRandomPositionOnSimulator(self.spaceModel))
        }
    }
}




//MARK: Simulator
private extension 🌐SpaceView {
    private struct SetRandomPositionOnSimulator: ViewModifier {
        var model: 🌐SpaceModel
        func body(content: Content) -> some View {
            content
#if targetEnvironment(simulator)
                .onTapGesture { self.model.setRandomPosition_simulator() }
#endif
        }
        init(_ model: 🌐SpaceModel) {
            self.model = model
        }
    }
}
