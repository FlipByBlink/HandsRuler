import SwiftUI

struct 🛠️AboutMenu: View {
    var body: some View {
        NavigationStack {
            List { ℹ️AboutAppContent() }
        }
        .tabItem { Label("About", systemImage: "info") }
    }
}
