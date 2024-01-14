import SwiftUI

struct 🛠️SettingView: View {
    @EnvironmentObject var model: 📱AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Mode", selection: self.$model.mode) {
                        ForEach(🪄Mode.allCases) {
                            Text($0.localizedTitle)
                        }
                    }
                }
                Section {
                    Picker("Unit", selection: self.$model.unit) {
                        ForEach(📏Unit.allCases) {
                            Text($0.value.symbol)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Unit")
                }
                if !self.model.presentImmersiveSpace {
                    Section {
                        Button("Restart measurement") {
                            Task {
                                await self.openImmersiveSpace(id: "measure")
                            }
                        }
                    }
                }
            }
            .font(.title)
            .navigationTitle("Setting")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.default, value: self.model.presentImmersiveSpace)
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
