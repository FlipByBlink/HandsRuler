import SwiftUI

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        TabView {
            NavigationStack {
                Group {
                    if self.model.logs.isEmpty {
                        🛠️OnboardView()
                    } else {
                        🛠️LogView()
                    }
                }
                .navigationTitle("HandsRuler")
                .toolbar {
                    Button(self.model.openedImmersiveSpace ? "Stop" : "Start") {
                        Task {
                            if self.model.openedImmersiveSpace {
                                await self.dismissImmersiveSpace()
                            } else {
                                await self.openImmersiveSpace(id: "immersiveSpace")
                            }
                        }
                    }
                    .font(.title2)
                    .buttonStyle(.borderedProminent)
                    .tint(self.model.openedImmersiveSpace ? .red : .green)
                    .animation(.default, value: self.model.openedImmersiveSpace)
                }
            }
            .tabItem { Label("Measure", systemImage: "ruler") }
            🛠️SettingPanel()
                .tabItem { Label("Option", systemImage: "gearshape") }
            NavigationStack {
                List { ℹ️AboutAppContent() }
            }
            .tabItem { Label("About", systemImage: "info") }
        }
        .frame(width: 600, height: 600)
        .task { self.model.observeAuthorizationStatus() }
        .onChange(of: self.scenePhase) { _, newValue in
            if newValue == .background,
               self.model.openedImmersiveSpace {
                Task { await self.dismissImmersiveSpace() }
            }
        }
    }
}
