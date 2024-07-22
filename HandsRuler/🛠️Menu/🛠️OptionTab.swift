import SwiftUI

struct 🛠️OptionTab: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker(selection: self.$model.unit) {
                        ForEach(📐Unit.allCases) { Text($0.symbol) }
                    } label: {
                        Label("Unit", systemImage: "lines.measurement.horizontal")
                    }
                }
            }
            .navigationTitle("Option")
        }
        .tabItem { Label("Option", systemImage: "gearshape") }
    }
}
