import SwiftUI

@main
struct HandsWidthApp: App {
    var body: some Scene {
        ImmersiveSpace(id: "measure") {
            ContentView()
        }
        WindowGroup(id: "setting") {
            SettingView()
        }
        .defaultSize(width: 400, height: 600)
    }
    init() {
        📍AnchorComponent.registerComponent()
        📍AnchorSystem.registerSystem()
    }
}
