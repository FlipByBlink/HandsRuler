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
        } attachments: {
            Attachment(id: Self.attachmentID) {
                TimelineView(.periodic(from: .now, by: 0.2)) { _ in
                    Text(self.spaceModel.resultText)
                        .font(.system(size: self.spaceModel.labelFontSize))
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .padding(12)
                        .padding(.horizontal, 4)
                        .glassBackgroundEffect()
                        .modifier(Self.SetRandomPositionOnSimulator(self.spaceModel))
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
