import SwiftUI
import RealityKit
import ARKit

struct 🌐RealityView: View {
    @StateObject var model: 🥽AppModel = .init()
    var body: some View {
        RealityView { content, attachments in
            content.add(self.model.rootEntity)
            self.model.setUpChildEntities()
            
            let resultLabelEntity = attachments.entity(for: Self.attachmentID)!
            resultLabelEntity.components.set(🧑HeadTrackingComponent())
            resultLabelEntity.name = 🧩Name.resultLabel
            self.model.rootEntity.addChild(resultLabelEntity)
            
            self.model.setUp_simulator()
        } attachments: {
            Attachment(id: Self.attachmentID) {
                TimelineView(.periodic(from: .now, by: 0.2)) { _ in
                    Text(self.model.resultText)
                        .font(.system(size: self.model.labelFontSize))
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .padding(12)
                        .padding(.horizontal, 4)
                        .glassBackgroundEffect()
                        .modifier(Self.SetRandomPositionOnSimulator(self.model))
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { self.model.changeSelection($0.entity) }
        )
        .background { 
            🛠️MenuTop()
                .environmentObject(self.model)
        }
        .task { self.model.run() }
        .task { self.model.observeAuthorizationStatus() }
    }
    static let attachmentID: String = "resultLabel"
}




//MARK: Simulator
private extension 🌐RealityView {
    private struct SetRandomPositionOnSimulator: ViewModifier {
        var model: 🥽AppModel
        func body(content: Content) -> some View {
            content
#if targetEnvironment(simulator)
                .onTapGesture { self.model.setRandomPosition_simulator() }
#endif
        }
        init(_ model: 🥽AppModel) {
            self.model = model
        }
    }
}
