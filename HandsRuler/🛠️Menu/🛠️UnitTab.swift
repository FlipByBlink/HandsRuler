import SwiftUI

struct 🛠️UnitTab: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        NavigationStack {
            List {
                Picker("Unit", selection: self.$model.unit) {
                    ForEach(📐Unit.allCases) { unit in
                        HStack(alignment: .firstTextBaseline, spacing: 16) {
                            Text(unit.title)
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(unit.symbol)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            .navigationTitle("Unit")
        }
        .tabItem { Label("Unit", systemImage: "gearshape") }
    }
}
