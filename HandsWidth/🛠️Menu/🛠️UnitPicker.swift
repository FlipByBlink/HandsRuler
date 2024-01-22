import SwiftUI

struct 🛠️UnitPicker: View {
    @AppStorage("unit") var unit: 📏Unit = .meters
    var body: some View {
        HStack(spacing: 24) {
            Text("Unit")
            Picker("Unit", selection: self.$unit) {
                ForEach(📏Unit.allCases) {
                    Text($0.value.symbol)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 360)
        }
        .font(.title.weight(.medium))
    }
}
