import SwiftUI

@main
struct HandsWidthApp: App {
    var body: some Scene {
        ImmersiveSpace {
            ContentView()
        }
    }
    init() {
        🧑HeadTrackingComponent.registerComponent()
        🧑HeadTrackingSystem.registerSystem()
    }
}
