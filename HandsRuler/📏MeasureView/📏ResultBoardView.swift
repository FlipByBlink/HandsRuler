import SwiftUI

struct 📏ResultBoardView: View {
    @EnvironmentObject var model: 🥽AppModel
    private var lineLength: Float
    var body: some View {
        Text(🪧ResultFormatter.string(self.lineLength, self.model.unit))
            .font(.system(size: max(.init(min(self.lineLength * 30, 36)), 20)))
            .fontWeight(.bold)
            .monospacedDigit()
            .padding(12)
            .padding(.horizontal, 4)
            .contentShape(.capsule)
            .glassBackgroundEffect()
            .onTapGesture { self.model.setRandomPosition_simulator() }
    }
    init(_ lineLength: Float) {
        self.lineLength = lineLength
    }
}

extension 📏ResultBoardView {
    struct FixedRuler: View {
        @EnvironmentObject var model: 🥽AppModel
        @State private var presentSubMenu: Bool = false
        private var id: UUID
        var body: some View {
            if let log = self.model.logs[self.id] {
                📏ResultBoardView(log.lineLength)
                    .hoverEffect()
                    .onTapGesture { self.presentSubMenu.toggle() }
                    .overlay(alignment: .bottom) {
                        VStack {
                            Button {
                                UIPasteboard.general.string = 🪧ResultFormatter.string(log.lineLength,
                                                                                       self.model.unit)
                                self.presentSubMenu = false
                            } label: {
                                Label("Copy as text", systemImage: "doc.on.doc")
                            }
                            .fixedSize()
                            Button(role: .destructive) {
                                self.model.removeLog(log)
                                self.presentSubMenu = false
                            } label: {
                                Label("Remove", systemImage: "delete.left")
                            }
                            .fixedSize()
                        }
                        .padding()
                        .font(.subheadline)
                        .glassBackgroundEffect()
                        .visualEffect { $0.offset(y: $1.size.height + 12) }
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
