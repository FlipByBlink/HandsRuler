import SwiftUI

@main
struct HandsWidthApp: App {
    @StateObject private var model: 📱AppModel = .init()
    var body: some Scene {
        ImmersiveSpace {
            ContentView()
                .environmentObject(self.model)
        }
        WindowGroup(id: "setting") {
            🛠️SettingView()
                .environmentObject(self.model)
        }
        .defaultSize(width: 400, height: 340)
    }
    init() {
        🧑HeadTrackingComponent.registerComponent()
        🧑HeadTrackingSystem.registerSystem()
    }
}
