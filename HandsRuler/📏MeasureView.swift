import SwiftUI
import RealityKit
import ARKit

struct 📏MeasureView: View {
    @StateObject private var model: 📏MeasureModel = .init()
    var body: some View {
        RealityView { content, attachments in
            content.add(self.model.rootEntity)
            self.model.setUpChildEntities()
            
            let resultEntity = attachments.entity(for: "result")!
            resultEntity.components.set(🧑HeadTrackingComponent())
            resultEntity.name = "result"
            self.model.rootEntity.addChild(resultEntity)
            
            self.model.setUp_simulator()
        } update: { _, attachments in
            self.model.logs.elements.forEach { log in
                let fixedResultEntity = attachments.entity(for: "\(log.id)")!
                fixedResultEntity.components.set(🧑HeadTrackingComponent())
                fixedResultEntity.position = (log.leftPosition + log.rightPosition) / 2
                if let fixedRulerEntity = self.model.rootEntity.findEntity(named: "\(log.id)") {
                    fixedRulerEntity.addChild(fixedResultEntity)
                }
            }
            //重複してentityが追加されてないか後日チェックする
        } attachments: {
            Attachment(id: "result") {
                self.resultView(self.model.resultValue)
            }
            ForEach(self.model.logs.elements) { log in
                Attachment(id: "\(log.id)") {
                    self.resultView(log.lineLength)
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { self.model.tap($0.entity) }
        )
        .task { self.model.run() }
        .onChange(of: self.model.logs, self.updateRemovedFixedRuler(_:_:))
    }
}

private extension 📏MeasureView {
    private func resultView(_ lineLength: Float) -> some View {
        Text(🪧ResultFormatter.string(lineLength, self.model.unit))
            .font(.system(size: max(.init(lineLength * 30), 20)))
            .fontWeight(.bold)
            .monospacedDigit()
            .padding(12)
            .padding(.horizontal, 4)
            .glassBackgroundEffect()
            .modifier(Self.SetRandomPosition_Simulator(self.model))
    }
    private func updateRemovedFixedRuler(_ oldValue: 💾Logs, _ newValue: 💾Logs) {
        //これはworldTrackingProviderが動く実機なら必要ないかも
        oldValue.elements.forEach { log in
            if !newValue.elements.contains(log) {
                self.model.rootEntity.findEntity(named: "\(log.id)")?.removeFromParent()
            }
        }
    }
}




//MARK: Simulator
private extension 📏MeasureView {
    private struct SetRandomPosition_Simulator: ViewModifier {
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
