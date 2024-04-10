import SwiftUI

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.scenePhase) var scenePhase
    @Binding var openedImmersiveSpace: Bool
    @AppStorage("logsData") var logsData: Data?
    @AppStorage("measureOnLaunch") var measureOnLaunch: Bool = false
    var body: some View {
        TabView {
            NavigationStack {
                Group {
                    if self.logsData == nil {
                        🛠️OnboardView()
                    } else {
                        🛠️LogView()
                    }
                }
                .navigationTitle("HandsRuler")
                .toolbar { self.startOrStopButton() }
            }
            .tabItem { Label("Measure", systemImage: "ruler") }
            🛠️OptionTab()
            🛠️GuideTab()
            🛠️AboutTab()
            🛠️RequestTab()
        }
        .frame(width: 600, height: 600)
        .onChange(of: self.scenePhase) { _, newValue in
            if newValue == .background,
               self.openedImmersiveSpace {
                Task { await self.dismissImmersiveSpace() }
            }
        }
        .task {
            if self.measureOnLaunch,
               !self.openedImmersiveSpace {
                await self.openImmersiveSpace(id: "measure")
                self.openedImmersiveSpace = true
            }
        }
    }
    init(_ openedImmersiveSpace: Binding<Bool>) {
        self._openedImmersiveSpace = openedImmersiveSpace
    }
}

private extension ContentView {
    private func startOrStopButton() -> some View {
        Button(self.openedImmersiveSpace ? "Stop" : "Start") {
            Task { @MainActor in
                if self.openedImmersiveSpace {
                    await self.dismissImmersiveSpace()
                } else {
                    await self.openImmersiveSpace(id: "measure")
                    self.openedImmersiveSpace = true
                }
            }
        }
        .font(.title2)
        .buttonStyle(.borderedProminent)
        .tint(self.openedImmersiveSpace ? .red : .green)
        .animation(.default, value: self.openedImmersiveSpace)
    }
}
