import SwiftUI

struct 📏ResultBoardView: View {
    @EnvironmentObject var model: 🥽AppModel
    private var lineLength: Float
    private var isFixedRuler: Bool
    var body: some View {
        Text(🧾ResultFormatter.string(self.lineLength, self.model.unit))
            .font(.system(size: max(.init(min(self.lineLength * 22, 36)), 20)))
            .fontWeight(.bold)
            .monospacedDigit()
            .padding(12)
            .padding(.horizontal, 4)
            .contentShape(.capsule)
            .hoverEffect(isEnabled: self.isFixedRuler)
            .glassBackgroundEffect()
            .onTapGesture(count: 2) { self.model.setRandomPosition_simulator() }
    }
    init(_ lineLength: Float, isFixedRuler: Bool = false) {
        self.lineLength = lineLength
        self.isFixedRuler = isFixedRuler
    }
}

extension 📏ResultBoardView {
    struct FixedRuler: View {
        @EnvironmentObject var model: 🥽AppModel
        @State private var presentSubMenu: Bool = false
        private var id: UUID
        var body: some View {
            if let log = self.model.logs[self.id] {
                📏ResultBoardView(log.lineLength, isFixedRuler: true)
                    .onTapGesture { self.presentSubMenu.toggle() }
                    .overlay(alignment: .bottom) {
                        VStack(spacing: 20) {
                            Button {
                                UIPasteboard.general.string = 🧾ResultFormatter.string(log.lineLength,
                                                                                       self.model.unit)
                                Task {
                                    try? await Task.sleep(for: .seconds(0.3))
                                    self.presentSubMenu = false
                                }
                            } label: {
                                Label("Copy as text", systemImage: "doc.on.doc")
                                    .padding(.vertical, 8)
                            }
                            .fixedSize()
                            Button(role: .destructive) {
                                self.model.removeLog(log)
                                self.presentSubMenu = false
                            } label: {
                                Label("Remove", systemImage: "delete.left")
                                    .padding(.vertical, 8)
                            }
                            .fixedSize()
                        }
                        .font(.title2)
                        .padding(24)
                        .glassBackgroundEffect()
                        .visualEffect { $0.offset(y: $1.size.height + 16) }
                        .opacity(self.presentSubMenu ? 1 : 0)
                        .animation(.default.speed(2), value: self.presentSubMenu)
                    }
            }
        }
        init(_ id: UUID) {
            self.id = id
        }
    }
}
