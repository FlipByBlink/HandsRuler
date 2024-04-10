import SwiftUI

struct 🛠️OptionTab: View {
    @AppStorage("unit") var unit: 📐Unit = .meters
    @AppStorage("measureOnLaunch") var measureOnLaunch: Bool = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(selection: self.$unit) {
                        ForEach(📐Unit.allCases) { Text($0.symbol) }
                    } label: {
                        Label("Unit", systemImage: "lines.measurement.horizontal")
                    }
                }
                Section {
                    Toggle(isOn: self.$measureOnLaunch) {
                        Label("Start measuring on launch",
                              systemImage: "wand.and.stars")
                    }
                }
            }
            .navigationTitle("Option")
        }
        .tabItem { Label("Option", systemImage: "gearshape") }
    }
}
