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
            📏MeasureView()
                .onDisappear {
                    self.model.openedImmersiveSpace = false
                }
        }
    }
    init() {
        🧑HeadTrackingComponent.registerComponent()
        🧑HeadTrackingSystem.registerSystem()
    }
}
