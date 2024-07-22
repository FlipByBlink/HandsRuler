import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: 🥽AppModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        TabView {
            🛠️MeasureTab()
            🛠️OptionTab()
            🛠️GuideTab()
            🛠️AboutTab()
            🛠️RequestTab()
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
