import SwiftUI
import ARKit

@MainActor
class 🥽AppModel: ObservableObject {
    @AppStorage("unit") var unit: 📐Unit = .meters
    @AppStorage("measureOnLaunch") var measureOnLaunch: Bool = false
    
    @Published var resultValue: Float = 0.4
    @Published var openedImmersiveSpace: Bool = false
    @Published var logs: 💾Logs = .load()
    
    let arKitSession = ARKitSession()
    let handTrackingProvider = HandTrackingProvider()
    let worldTrackingProvider = WorldTrackingProvider()
    
    let entities = 🧩Entities()
    
    var selection: 🔵Selection = .noSelect
    let sounds = 📢Sounds()
}
