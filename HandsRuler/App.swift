import SwiftUI

@main
struct HandsRulerApp: App {
    @StateObject private var model = 🥽AppModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.model)
        }
        .windowResizability(.contentSize)
        ImmersiveSpace(id: "measure") {
            📏MeasureView()
                .environmentObject(self.model)
//                .task { self.model.setPlaceholderFixedRulers_simulator() }
        }
    }
    init() {
        🧑HeadTrackingComponent.registerComponent()
        🧑HeadTrackingSystem.registerSystem()
    }
}
