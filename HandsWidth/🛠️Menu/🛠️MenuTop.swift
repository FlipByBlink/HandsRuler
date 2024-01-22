import SwiftUI

struct 🛠️MenuTop: View {
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @State private var presentPanel: Panel? = .info
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 24) {
                Button {
                    Task { await self.dismissImmersiveSpace() }
                } label: {
                    Label("Close", systemImage: "escape")
                        .labelStyle(.iconOnly)
                        .font(.title.weight(.regular))
                        .frame(width: 60, height: 60)
                }
                .buttonBorderShape(.circle)
                .glassBackgroundEffect()
                Button {
                    self.presentPanel = .setting
                } label: {
                    Label("Setting", systemImage: "gearshape")
                        .labelStyle(.iconOnly)
                        .font(.title.weight(.light))
                        .frame(width: 60, height: 60)
                }
                .disabled(self.presentPanel == .setting)
                .buttonBorderShape(.circle)
                .glassBackgroundEffect()
                Button {
                    self.presentPanel = .info
                } label: {
                    Label("Info", systemImage: "info")
                        .labelStyle(.iconOnly)
                        .font(.title.weight(.light))
                        .frame(width: 60, height: 60)
                }
                .disabled(self.presentPanel == .info)
                .buttonBorderShape(.circle)
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
                🛠️InfoMenu()
                    .overlay(alignment: .topTrailing) { self.hideButton() }
                    .padding(32)
                    .padding(.horizontal)
                    .fixedSize()
                    .glassBackgroundEffect()
                    .opacity(self.presentPanel == .info ? 1 : 0)
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
    case setting, info
}
