import SwiftUI

@MainActor
class 🥽AppModel: ObservableObject {
    @AppStorage("unit") var unit: 📐Unit = .meters
    @AppStorage("measureOnLaunch") var measureOnLaunch: Bool = false
    @AppStorage("logsData") var logsData: Data?
    @Published var openedImmersiveSpace: Bool = false
}
