import SwiftUI
import ARKit

@MainActor
class 🥽AppModel: ObservableObject {
    @AppStorage("unit") var unit: 📐Unit = .meters
    
    @Published var mode: 🎚️Mode = .normal
    @Published var logs: 💾Logs = .load()
    @Published var activeWorldAnchors: [WorldAnchor] = []
    @Published var openedImmersiveSpace: Bool = false
    
    let arKitSession = ARKitSession()
    let handTrackingProvider = HandTrackingProvider()
    let worldTrackingProvider = WorldTrackingProvider()
    let sceneReconstructionProvider = SceneReconstructionProvider()
    
    let entities = 🧩Entities()
    
    var selection: 🔵Selection = .noSelect
    var isCooldownActive: Bool = false
    let sounds = 📢Sounds()
    var currentHits: [SIMD3<Float>] = []
}
