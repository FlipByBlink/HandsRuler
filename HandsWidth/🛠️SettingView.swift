import SwiftUI

struct 🛠️SettingView: View {
    @AppStorage("unit") var unit: 📏Unit = .meters
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
            HStack(spacing: 24) {
                Text("Unit")
                Picker("Unit", selection: self.$unit) {
                    ForEach(📏Unit.allCases) {
                        Text($0.value.symbol)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 360)
            }
            .font(.title.weight(.medium))
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
        .overlay {
            Button {
                self.minimized = false
            } label: {
                Label("Setting", systemImage: "gearshape")
                    .labelStyle(.iconOnly)
                    .font(.largeTitle.weight(.light))
                    .padding()
                    .foregroundStyle(.secondary)
            }
            .disabled(!self.minimized)
            .opacity(self.minimized ? 1 : 0)
        }
        .offset(y: -2200)
        .offset(z: -700)
        .animation(.default, value: self.minimized)
    }
}
