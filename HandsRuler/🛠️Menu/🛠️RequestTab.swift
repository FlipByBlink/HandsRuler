import SwiftUI

struct 🛠️RequestTab: View {
    @Environment(\.openURL) var openURL
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("""
                App Store
                review
                PLEASE!!!
                """)
                .multilineTextAlignment(.center)
                .font(.extraLargeTitle2)
                Button {
                    self.openURL(🗒️StaticInfo.appStoreUserReviewURL)
                } label: {
                    HStack {
                        Text("Go to App Store")
                        Image(systemName: "arrow.up.forward.app")
                            .symbolRenderingMode(.hierarchical)
                    }
                    .font(.largeTitle)
                    .padding(.vertical, 12)
                }
            }
            .padding(.bottom, 36)
            .navigationTitle("Request")
        }
        .tabItem { Label("Request", systemImage: "star.bubble") }
    }
}
