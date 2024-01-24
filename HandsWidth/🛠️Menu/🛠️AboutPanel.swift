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
            HStack(spacing: 28) {
                Image(.graph1)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 280)
                    .clipShape(.rect(cornerRadius: 24))
                VStack(spacing: 12) {
                    Image(.graph2)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .clipShape(.rect(cornerRadius: 16))
                    Text("Fix / Unfix a pointer by indirect tap.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal)
            HStack(spacing: 24) {
                Text("Hand tracking authorization:")
                    .font(.headline)
                if let authorizationStatus = self.model.authorizationStatus {
                    Text(authorizationStatus.description)
                        .font(.subheadline)
                } else {
                    ProgressView()
                }
            }
            .foregroundStyle(.secondary)
            .frame(height: 60)
        }
    }
}
