import SwiftUI

struct 🛠️MeasureTab: View {
    @EnvironmentObject var model: 🥽AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var body: some View {
        NavigationStack {
            Group {
                if self.model.logs.hasNeverLogged {
                    🛠️OnboardView()
                } else {
                    🛠️LogsView()
                }
            }
            .navigationTitle("HandsRuler")
            .toolbar {
                self.startOrStopButton()
                Picker("Mode", selection: self.$model.mode) {
                    ForEach(🎚️Mode.allCases) {
                        Text("\($0)")
                    }
                }
                .onChange(of: self.model.mode) { _, _ in
                    self.model.applyModeState()
                }
            }
        }
        .animation(.default, value: self.model.logs)
        .tabItem { Label("Measure", systemImage: "ruler") }
    }
}

private extension 🛠️MeasureTab {
    private func startOrStopButton() -> some View {
        Button(self.model.openedImmersiveSpace ? "Stop" : "Start") {
            Task { @MainActor in
                if self.model.openedImmersiveSpace {
                    await self.dismissImmersiveSpace()
                } else {
                    await self.openImmersiveSpace(id: "measure")
                    self.model.openedImmersiveSpace = true
                }
            }
        }
        .font(.largeTitle)
        .buttonStyle(.borderedProminent)
        .tint(self.model.openedImmersiveSpace ? .red : .green)
        .animation(.default, value: self.model.openedImmersiveSpace)
    }
}
