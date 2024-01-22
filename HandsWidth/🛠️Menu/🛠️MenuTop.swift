import SwiftUI

struct 🛠️MenuBoard: View {
    @State private var presentPanel: Panel? = nil
    var body: some View {
        VStack(spacing: 24) {
            HStack(spacing: 24) {
                Button {
                } label: {
                    Label("Close", systemImage: "escape")
                        .labelStyle(.iconOnly)
                        .font(.title.weight(.light))
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
                .buttonBorderShape(.circle)
                .glassBackgroundEffect()
                .disabled(true)
                Button {
                    self.presentPanel = .info
                } label: {
                    Label("Info", systemImage: "info")
                        .labelStyle(.iconOnly)
                        .font(.title)
                        .frame(width: 60, height: 60)
                }
                .buttonBorderShape(.circle)
                .glassBackgroundEffect()
            }
            🛠️SettingView()
        }
        .offset(y: -2200)
        .offset(z: -700)
    }
}

enum Panel {
    case setting, info
}
