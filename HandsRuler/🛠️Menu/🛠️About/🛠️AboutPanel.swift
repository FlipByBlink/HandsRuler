import SwiftUI

struct 🛠️AboutPanel: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 20) {
                        Image(.graph1)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300)
                            .clipShape(.rect(cornerRadius: 8, style: .continuous))
                        Text("Measurement of the distance between the fingers.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .padding(4)
                }
                Section {
                    HStack(spacing: 20) {
                        Image(.graph2)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300)
                            .clipShape(.rect(cornerRadius: 8, style: .continuous))
                        Text("Fix / Unfix a pointer by indirect tap.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    .padding(4)
                }
                switch self.model.authorizationStatus {
                    case .notDetermined, .denied:
                        HStack(spacing: 24) {
                            Text("Hand tracking authorization:")
                                .fontWeight(.semibold)
                            Text(self.model.authorizationStatus?.description ?? "nil")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    default:
                        EmptyView()
                }
                Section {
                    NavigationLink {
                        List {
                            ℹ️AboutAppContent()
                        }
                    } label: {
                        Label("About App", systemImage: "questionmark")
                    }
                }
            }
            .navigationTitle("About")
        }
        .frame(width: 640, height: 500)
    }
}
