import SwiftUI

struct ContentView: View {
    @EnvironmentObject var model: 📱AppModel
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        🌐RealityView()
            .task {
                if !self.model.presentSettingWindow {
                    self.openWindow(id: "setting")
                }
            }
            .onAppear { self.model.presentImmersiveSpace = true }
            .onChange(of: self.scenePhase) { _, newValue in
                switch newValue {
                    case .inactive, .background: self.model.presentImmersiveSpace = false
                    default: break
                }
            }
            .onChange(of: self.model.presentSettingWindow) { _, newValue in
                if newValue == false {
                    Task { await self.dismissImmersiveSpace() }
                }
            }
    }
}
