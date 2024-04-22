import SwiftUI

struct 📏ResultBoardView: View {
    @EnvironmentObject var model: 🥽AppModel
    @State private var presentSubMenu: Bool = false
    private var lineLength: Float
    private var log: 💾Log?
    var body: some View {
        Text(🪧ResultFormatter.string(self.lineLength, self.model.unit))
            .font(.system(size: max(.init(min(self.lineLength * 30, 36)), 20)))
            .fontWeight(.bold)
            .monospacedDigit()
            .padding(12)
            .padding(.horizontal, 4)
            .contentShape(.capsule)
            .hoverEffect(isEnabled: self.log != nil)
            .glassBackgroundEffect()
            .onTapGesture {
                if self.log != nil {
                    self.presentSubMenu.toggle()
                } else {
                    self.model.setRandomPosition_simulator()
                }
            }
            .overlay(alignment: .bottom) {
                VStack {
                    Button {
                        if let log {
                            UIPasteboard.general.string = 🪧ResultFormatter.string(log.lineLength,
                                                                                   self.model.unit)
                            self.presentSubMenu = false
                        }
                    } label: {
                        Label("Copy as text", systemImage: "doc.on.doc")
                    }
                    .fixedSize()
                    Button(role: .destructive) {
                        if let log {
                            self.model.removeLog(log)
                            self.presentSubMenu = false
                        }
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
    init(_ lineLength: Float, _ log: 💾Log? = nil) {
        self.lineLength = lineLength
        self.log = log
    }
}
