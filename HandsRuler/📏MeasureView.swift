import SwiftUI
import RealityKit
import ARKit

struct 📏MeasureView: View {
    @StateObject private var measureModel: 📏MeasureModel = .init()
    @EnvironmentObject var appModel: 🥽AppModel
    var body: some View {
        RealityView { content, attachments in
            content.add(self.measureModel.rootEntity)
            self.measureModel.setUpChildEntities()
            
            let resultEntity = attachments.entity(for: "result")!
            resultEntity.components.set(🧑HeadTrackingComponent())
            resultEntity.name = "result"
            self.measureModel.rootEntity.addChild(resultEntity)
            
            self.measureModel.setUp_simulator()
        } update: { _, attachments in
            self.appModel.logs.elements.forEach { log in
                if self.measureModel.rootEntity.findEntity(named: "\(log.id)") == nil {
                    let fixedResultEntity = attachments.entity(for: "\(log.id)")!
                    fixedResultEntity.components.set(🧑HeadTrackingComponent())
                    fixedResultEntity.name = "\(log.id)"
                    self.measureModel.rootEntity.addChild(fixedResultEntity)
                }
            }
        } attachments: {
            Attachment(id: "result") {
                self.resultView(self.measureModel.resultModel)
            }
            ForEach(self.appModel.logs.elements) { log in
                Attachment(id: "\(log.id)") {
                    self.resultView(.init(log.lineLength, self.measureModel.unit))
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded {
                    if self.measureModel.shouldLog($0.entity) {
                        self.appModel.add(self.measureModel.createLog())
                    }
                    self.measureModel.tap($0.entity)
                }
        )
        .task { self.measureModel.run() }
    }
}

private extension 📏MeasureView {
    private func resultView(_ resultModel: 🪧ResultModel) -> some View {
        Text(resultModel.label)
            .font(.system(size: resultModel.size))
            .fontWeight(.bold)
            .monospacedDigit()
            .padding(12)
            .padding(.horizontal, 4)
            .glassBackgroundEffect()
            .modifier(Self.SetRandomPositionOnSimulator(self.measureModel))
    }
}




//MARK: Simulator
private extension 📏MeasureView {
    private struct SetRandomPositionOnSimulator: ViewModifier {
        var model: 📏MeasureModel
        func body(content: Content) -> some View {
            content
#if targetEnvironment(simulator)
                .onTapGesture { self.model.setRandomPosition_simulator() }
#endif
        }
        init(_ model: 📏MeasureModel) {
            self.model = model
        }
    }
}
