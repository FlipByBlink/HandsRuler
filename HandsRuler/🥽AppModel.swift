import SwiftUI

@MainActor
class 🥽AppModel: ObservableObject {
    @AppStorage("unit") var unit: 📐Unit = .meters
    @AppStorage("measureOnLaunch") var measureOnLaunch: Bool = false
    @AppStorage("logsData") var logsData: Data?
    @Published var openedImmersiveSpace: Bool = false
}

extension 🥽AppModel {
    var logs: 💾Logs { .load(self.logsData) }
    func add(_ log: 💾Log) {
        self.logs.add(log)
        AudioServicesPlaySystemSound(1105) //TODO: あとで再実装
    }
}

import AudioToolbox
