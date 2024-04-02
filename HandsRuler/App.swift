import SwiftUI

@main
struct HandsRulerApp: App {
    @State private var openedImmersiveSpace: Bool = false
    var body: some Scene {
        WindowGroup {
            ContentView(self.$openedImmersiveSpace)
        }
        .windowResizability(.contentSize)
        ImmersiveSpace(id: "ruler") {
            📏RulerView()
                .onDisappear {
                    self.openedImmersiveSpace = false
                }
        }
    }
    init() {
        🧑HeadTrackingComponent.registerComponent()
        🧑HeadTrackingSystem.registerSystem()
    }
}
