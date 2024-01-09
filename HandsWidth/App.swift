import SwiftUI

@main
struct HandsWidthApp: App {
    @StateObject private var model: AppModel = .init()
    var body: some Scene {
        ImmersiveSpace(id: "measure") {
            ContentView()
                .environmentObject(self.model)
        }
        WindowGroup(id: "setting") {
            SettingView()
                .environmentObject(self.model)
        }
        .defaultSize(width: 300, height: 300)
    }
    init() {
        📍AnchorComponent.registerComponent()
        📍AnchorSystem.registerSystem()
    }
}
