import SwiftUI
import ARKit

struct 🛠️GuideTab: View {
    @State private var authorizationStatus: ARKitSession.AuthorizationStatus?
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 20) {
                        Image(.graph1)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240)
                            .clipShape(.rect(cornerRadius: 8, style: .continuous))
                        Text("Measurement of the distance between the fingers.")
                            .multilineTextAlignment(.center)
                    }
                    .padding(4)
                    HStack(spacing: 20) {
                        Image(.graph2)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 240)
                            .clipShape(.rect(cornerRadius: 8, style: .continuous))
                        Text("Fix / Unfix a pointer by indirect tap.")
                            .multilineTextAlignment(.center)
                    }
                    .padding(4)
                }
                switch self.authorizationStatus {
                    case .notDetermined, .denied:
                        HStack(spacing: 24) {
                            Text("Hand tracking authorization:")
                                .fontWeight(.semibold)
                            Text(self.authorizationStatus?.description ?? "nil")
                        }
                        .foregroundStyle(.secondary)
                    default:
                        EmptyView()
                }
            }
            .navigationTitle("Guide")
            .task { await self.observeAuthorizationStatus() }
        }
        .tabItem { Label("Guide", systemImage: "questionmark") }
    }
}

private extension 🛠️GuideTab {
    private func observeAuthorizationStatus() async {
        let session = ARKitSession()
        self.authorizationStatus = await session.queryAuthorization(for: [.handTracking])[.handTracking]
        
        for await update in session.events {
            if case .authorizationChanged(let type, let status) = update {
                if type == .handTracking { self.authorizationStatus = status }
            } else {
                print("Another session event \(update).")
            }
        }
    }
}
