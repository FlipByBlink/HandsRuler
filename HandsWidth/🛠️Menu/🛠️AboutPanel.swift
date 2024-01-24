import SwiftUI

struct 🛠️AboutPanel: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Text("HandsWidth")
                    .font(.largeTitle.weight(.semibold))
                Spacer()
            }
            .frame(height: 60)
            HStack(spacing: 32) {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 300, height: 200)
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 300, height: 200)
            }
            .padding(.horizontal)
            HStack {
                Text("Hand tracking authorization:")
                    .font(.headline)
                Text(self.model.authorizationStatus?.description ?? "...")
                    .font(.subheadline)
            }
            .foregroundStyle(.secondary)
            .frame(height: 60)
        }
    }
}
