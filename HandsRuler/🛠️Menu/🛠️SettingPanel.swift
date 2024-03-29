import SwiftUI

struct 🛠️SettingPanel: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(selection: self.$model.unit) {
                        ForEach(📏Unit.allCases) {
                            Text($0.value.symbol)
                        }
                    } label: {
                        Label("Unit", systemImage: "lines.measurement.horizontal")
                    }
                }
                Section {
                    Toggle(isOn: self.$model.measureOnLaunch) {
                        Label("Start measuring on launch",
                              systemImage: "wand.and.stars")
                    }
                }
            }
            .navigationTitle("Option")
        }
    }
}
