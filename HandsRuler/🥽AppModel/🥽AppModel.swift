import SwiftUI
import ARKit

@MainActor
class 🥽AppModel: ObservableObject {
    @AppStorage("unit") var unit: 📐Unit = .meters
    
    @Published var openedImmersiveSpace: Bool = false
    @Published var logs: 💾Logs = .load()
    @Published var activeWorldAnchors: [WorldAnchor] = []
    
    let arKitSession = ARKitSession()
    let handTrackingProvider = HandTrackingProvider()
    let worldTrackingProvider = WorldTrackingProvider()
    
    let entities = 🧩Entities()
    
    var selection: 🔵Selection = .noSelect
    let sounds = 📢Sounds()
}
