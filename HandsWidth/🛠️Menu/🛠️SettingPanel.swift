import SwiftUI

struct 🛠️SettingPanel: View {
    @State private var minimized: Bool = false
    var body: some View {
        VStack(spacing: 48) {
            HStack {
                Spacer()
                Text("Setting")
                    .font(.largeTitle.weight(.semibold))
                Spacer()
            }
            .frame(height: 60)
            🛠️UnitPicker()
            VStack {
                Text("Tip")
                    .font(.headline)
                Text("Fix a pointer by tap.")
                    .font(.subheadline)
            }
            .foregroundStyle(.tertiary)
        }
    }
}
