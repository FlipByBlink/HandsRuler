import SwiftUI
import RealityKit
import ARKit

struct 🌐SpaceView: View {
    @StateObject private var model: 🌐SpaceModel = .init()
    var body: some View {
        RealityView { content, attachments in
            content.add(self.model.rootEntity)
            self.model.setUpChildEntities()
            
            let resultLabelEntity = attachments.entity(for: Self.attachmentID)!
            resultLabelEntity.components.set(🧑HeadTrackingComponent())
            resultLabelEntity.name = 🧩Name.resultLabel
            self.model.rootEntity.addChild(resultLabelEntity)
            
            self.model.setUp_simulator()
        } update: { _, attachments in
            self.model.logs.elements.forEach { log in
                let resultLabelEntity = attachments.entity(for: "\(log.id)")!
                resultLabelEntity.components.set(🧑HeadTrackingComponent())
                resultLabelEntity.name = "\(log.id)"
                self.model.rootEntity.addChild(resultLabelEntity)
            }
        } attachments: {
            Attachment(id: Self.attachmentID) {
                self.resultLabelView(self.model.resultText, self.model.labelFontSize)
            }
            ForEach(self.model.logs.elements) { log in //この実装だとTimelineViewが機能しないようだ
                Attachment(id: "\(log.id)") {
                    self.resultLabelView("\(log.lineLength)", 30)
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { self.model.changeSelection($0.entity) }
        )
        .task { self.model.run() }
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
                .modifier(Self.SetRandomPositionOnSimulator(self.model))
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
