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
//        } update: { _, attachments in
        } update: { _, _ in
//            self.model.logs.elements.forEach { log in //TODO: Work in progress
//                let fixedResultEntity = attachments.entity(for: "\(log.id)")!
//                fixedResultEntity.components.set(🪧FixedResultComponent(worldAnchorID: log.id))
//                self.model.rootEntity.addChild(fixedResultEntity)
//            }
        } attachments: {
            Attachment(id: "result") {
                self.resultView(self.model.resultValue)
            }
            ForEach(self.model.logs.elements) { log in
                Attachment(id: "\(log.id)") {
                    self.resultView(log.lineLength, log)
                }
            }
        }
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { self.model.tap($0.entity) }
        )
        .task { self.model.run() }
    }
}

private extension 📏MeasureView {
    private func resultView(_ lineLength: Float, _ log: 💾Log? = nil) -> some View {
        Text(🪧ResultFormatter.string(lineLength, self.model.unit))
            .font(.system(size: max(.init(lineLength * 30), 20)))
            .fontWeight(.bold)
            .monospacedDigit()
            .padding(12)
            .padding(.horizontal, 4)
            .contentShape(.capsule)
            .hoverEffect(isEnabled: log != nil)
            .glassBackgroundEffect()
            .onTapGesture {
                if let log {
                    self.model.logs.remove(log)
                } else {
                    self.setRandomPosition_simulator()
                }
            }
    }
}




//MARK: Simulator
private extension 📏MeasureView {
    private func setRandomPosition_simulator() {
#if targetEnvironment(simulator)
        self.model.setRandomPosition_simulator()
#endif
    }
}
