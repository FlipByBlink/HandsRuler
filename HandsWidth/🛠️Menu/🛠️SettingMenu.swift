import SwiftUI

struct 🛠️SettingMenu: View {
    @State private var minimized: Bool = false
    var body: some View {
        VStack(spacing: 48) {
            HStack {
                Spacer()
                Text("Setting")
                    .font(.largeTitle.weight(.semibold))
                Spacer()
            }
            .overlay(alignment: .trailing) {
                Button {
                    self.minimized = true
                } label: {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .padding()
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.plain)
            }
            🛠️UnitPicker()
            VStack {
                Text("Tip")
                    .font(.headline)
                Text("Fix a pointer by tap.")
                    .font(.subheadline)
            }
            .foregroundStyle(.tertiary)
        }
        .padding(32)
        .padding(.horizontal)
        .fixedSize()
        .glassBackgroundEffect()
        .opacity(self.minimized ? 0 : 1)
        .animation(.default, value: self.minimized)
    }
}
