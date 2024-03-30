import SwiftUI
import RealityKit
import ARKit

struct 🌐SpaceView: View {
    @StateObject private var model: 🌐SpaceModel = .init()
    var body: some View {
        RealityView { content, attachments in
            content.add(self.model.rootEntity)
            self.model.setUpChildEntities()
            
            let resultEntity = attachments.entity(for: "result")!
            resultEntity.components.set(🧑HeadTrackingComponent())
            resultEntity.name = 🧩Name.result
            self.model.rootEntity.addChild(resultEntity)
            
            self.model.setUp_simulator()
        } update: { _, attachments in
            self.model.logs.elements.forEach { log in
                let fixedResultEntity = attachments.entity(for: "\(log.id)")!
                fixedResultEntity.components.set(🧑HeadTrackingComponent())
                fixedResultEntity.name = "\(log.id)"
                self.model.rootEntity.addChild(fixedResultEntity)
            }
        } attachments: {
            Attachment(id: "result") {
                self.resultView(self.model.resultModel)
            }
            ForEach(self.model.logs.elements) { log in
                Attachment(id: "\(log.id)") {
                    self.resultView(.init(log.lineLength, self.model.unit))
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
}

private extension 🌐SpaceView {
    private func resultView(_ resultModel: 🪧ResultModel) -> some View {
        Text(resultModel.label)
            .font(.system(size: resultModel.size))
            .fontWeight(.bold)
            .monospacedDigit()
            .padding(12)
            .padding(.horizontal, 4)
            .glassBackgroundEffect()
            .modifier(Self.SetRandomPositionOnSimulator(self.model))
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
