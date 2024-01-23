import SwiftUI

struct 🛠️MenuTop: View {
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @State private var presentPanel: Panel? = .about
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 28) {
                Button {
                    Task { await self.dismissImmersiveSpace() }
                } label: {
                    Label("Exit", systemImage: "escape")
                        .font(.title.weight(.regular))
                        .padding(.vertical, 12)
                }
                .glassBackgroundEffect()
                Button {
                    self.presentPanel = .setting
                } label: {
                    Label("Setting", systemImage: "gearshape")
                        .font(.title.weight(.light))
                        .padding(.vertical, 12)
                }
                .disabled(self.presentPanel == .setting)
                .glassBackgroundEffect()
                Button {
                    self.presentPanel = .about
                } label: {
                    Label("About", systemImage: "questionmark")
                        .font(.title.weight(.light))
                        .padding(.vertical, 12)
                }
                .disabled(self.presentPanel == .about)
                .glassBackgroundEffect()
            }
            ZStack(alignment: .top) {
                🛠️SettingMenu()
                    .overlay(alignment: .topTrailing) { self.hideButton() }
                    .padding(32)
                    .padding(.horizontal)
                    .fixedSize()
                    .glassBackgroundEffect()
                    .opacity(self.presentPanel == .setting ? 1 : 0)
                🛠️AboutMenu()
                    .overlay(alignment: .topTrailing) { self.hideButton() }
                    .padding(32)
                    .padding(.horizontal)
                    .fixedSize()
                    .glassBackgroundEffect()
                    .opacity(self.presentPanel == .about ? 1 : 0)
            }
            .animation(.default, value: self.presentPanel)
        }
        .offset(y: -2200)
        .offset(z: -700)
    }
    private func hideButton() -> some View {
        Button {
            self.presentPanel = nil
        } label: {
            Image(systemName: "arrow.down.right.and.arrow.up.left")
                .padding()
        }
        .buttonBorderShape(.circle)
        .buttonStyle(.plain)
        .frame(width: 60, height: 60)
    }
}

enum Panel {
    case setting, about
}
