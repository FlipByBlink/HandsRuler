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
                    if self.model.logsData == nil {
                        🛠️OnboardView()
                    } else {
                        🛠️LogView()
                    }
                }
                .navigationTitle("HandsRuler")
                .toolbar { self.startOrStopButton() }
                .toolbar {
                    ToolbarItem(placement: .bottomOrnament) {
                        Button("Set debug value") { 💾Logs.setDebugValue() }
                    }
                }
            }
            .tabItem { Label("Measure", systemImage: "ruler") }
            🛠️SettingMenu()
            🛠️GuideMenu()
            🛠️AboutMenu()
        }
        .frame(width: 600, height: 600)
        .onChange(of: self.scenePhase) { _, newValue in
            if newValue == .background,
               self.model.openedImmersiveSpace {
                Task { await self.dismissImmersiveSpace() }
            }
        }
    }
}

private extension ContentView {
    private func startOrStopButton() -> some View {
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
