import SwiftUI

@main
struct HandsRulerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        ImmersiveSpace(id: "immersiveSpace") {
            🌐RealityView()
        }
    }
    init() {
        🧑HeadTrackingComponent.registerComponent()
        🧑HeadTrackingSystem.registerSystem()
    }
}
