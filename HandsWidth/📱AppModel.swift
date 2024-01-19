import SwiftUI

@MainActor
class 📱AppModel: ObservableObject {
    @Published var presentImmersiveSpace: Bool = false
    @Published var presentSettingWindow: Bool = false
}
