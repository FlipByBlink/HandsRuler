import SwiftUI

struct 📏ResultBoardViewForFixedRuler: View {
    @EnvironmentObject var model: 🥽AppModel
    @State private var presentSubMenu: Bool = false
    private var id: UUID
    var body: some View {
        if let log = self.model.logs[self.id] {
            📏ResultBoardLabel(log.lineLength, isFixedRuler: true)
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
