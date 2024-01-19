import SwiftUI

struct 🛠️SettingView: View {
    @EnvironmentObject var model: 📱AppModel
    @AppStorage("unit") var unit: 📏Unit = .meters
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        NavigationStack {
            List {
                Picker("Unit", selection: self.$unit) {
                    ForEach(📏Unit.allCases) {
                        Text($0.value.symbol)
                            .font(.largeTitle)
                    }
                }
            }
            .font(.title)
            .navigationTitle("HandsWidth")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { self.model.presentSettingWindow = true }
        .onChange(of: self.scenePhase) { _, newValue in
            switch newValue {
                case .inactive, .background: self.model.presentSettingWindow = false
                default: break
            }
        }
        .onChange(of: self.model.presentImmersiveSpace) { _, newValue in
            if newValue == false { self.dismissWindow() }
        }
    }
}
