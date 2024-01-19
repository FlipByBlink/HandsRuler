import SwiftUI

@MainActor
class 📱AppModel: ObservableObject {
    @Published var presentImmersiveSpace: Bool = false
    @Published var presentSettingWindow: Bool = false
}

//fileprivate extension 📱AppModel {
//#if targetEnvironment(simulator)
//    func setUp_simulator() {
//        self.updateResultLabel()
//        self.updateLine()
//    }
//#endif
//}
