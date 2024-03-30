import SwiftUI

@main
struct HandsRulerApp: App {
    @StateObject var model: 🥽AppModel = .init()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.model)
        }
        .windowResizability(.contentSize)
        ImmersiveSpace(id: "immersiveSpace") {
            🌐SpaceView()
                .environmentObject(self.model)
                .onAppear { self.model.openedImmersiveSpace = true }
                .onDisappear { self.model.openedImmersiveSpace = false }
        }
    }
    init() {
        🧑HeadTrackingComponent.registerComponent()
        🧑HeadTrackingSystem.registerSystem()
    }
}
