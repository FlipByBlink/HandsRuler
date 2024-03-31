import SwiftUI
import RealityKit
import ARKit

struct 📏MeasureView: View {
    @EnvironmentObject var appModel: 🥽AppModel
    @StateObject private var measureModel: 📏MeasureModel = .init()
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
                let fixedResultEntity = attachments.entity(for: "\(log.id)")!
//                fixedResultEntity.components.set(🧑HeadTrackingComponent())
                fixedResultEntity.name = "fixedResult\(log.id)"
                if let centerEntity = self.measureModel.rootEntity.findEntity(named: "\(log.centerID)") {
                    centerEntity.addChild(fixedResultEntity)
                }
            }
            //重複してentityが追加されてないか後日チェックする
        } attachments: {
            Attachment(id: "result") {
                self.resultView(self.measureModel.resultValue)
            }
            ForEach(self.appModel.logs.elements) { log in
                Attachment(id: "\(log.id)") {
                    self.resultView(log.lineLength)
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded {
                    if self.measureModel.shouldLog($0.entity) {
                        self.appModel.logs.add(self.measureModel.createLog())
                        $0.entity.playAudio(self.measureModel.sounds.fix)
                    }
                    self.measureModel.tap($0.entity)
                }
        )
        .task { self.measureModel.run() }
    }
}

private extension 📏MeasureView {
    private func resultView(_ lineLength: Float) -> some View {
        Text(🪧ResultFormatter.string(lineLength, self.measureModel.unit))
            .font(.system(size: max(.init(lineLength * 30), 20)))
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
