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
            }
            .tabItem { Label("Measure", systemImage: "ruler") }
            🛠️OptionMenu()
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
        .task {
            if self.model.measureOnLaunch,
               !self.model.openedImmersiveSpace {
                await self.openImmersiveSpace(id: "immersiveSpace")
                self.model.openedImmersiveSpace = true
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
                    self.model.openedImmersiveSpace = true
                }
            }
        }
        .font(.title2)
        .buttonStyle(.borderedProminent)
        .tint(self.model.openedImmersiveSpace ? .red : .green)
        .animation(.default, value: self.model.openedImmersiveSpace)
    }
}
