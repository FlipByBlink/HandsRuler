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
        .onChange(of: self.model.logs, self.updateRemovedFixedRuler(_:_:))
    }
}

private extension 📏MeasureView {
    private func resultView(_ lineLength: Float, _ log: 💾Log? = nil) -> some View {
        Text(🪧ResultFormatter.string(lineLength, self.model.unit))
            .font(.system(size: max(.init(min(lineLength * 30, 36)), 20)))
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
    private func updateRemovedFixedRuler(_ oldValue: 💾Logs, _ newValue: 💾Logs) { //TODO: 実装再検討
        oldValue.elements.forEach { log in
            if !newValue.elements.contains(log) {
                self.model.rootEntity.findEntity(named: "\(log.id)")?.removeFromParent()
                Task {
                    try? await self.model.worldTrackingProvider.removeAnchor(forID: log.id)
                }
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
