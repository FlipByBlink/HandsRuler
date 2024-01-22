import SwiftUI

struct 🛠️SettingButton: View {
    var body: some View {
        Button {
        } label: {
            Label("Setting", systemImage: "gearshape")
                .labelStyle(.iconOnly)
                .font(.title.weight(.light))
                .padding()
        }
        .buttonBorderShape(.circle)
        .glassBackgroundEffect()
        .disabled(true)
    }
}
