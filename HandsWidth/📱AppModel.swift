import SwiftUI

class 📱AppModel: ObservableObject {
    @Published var unit: 📏Unit = .meters
    @Published var presentImmersiveSpace: Bool = false
    @Published var presentSettingWindow: Bool = false
}

extension 📱AppModel {
}

fileprivate extension 📱AppModel {
}
