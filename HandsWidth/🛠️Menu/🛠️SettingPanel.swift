import SwiftUI

struct 🛠️SettingPanel: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        VStack(spacing: 32) {
            HStack {
                Spacer()
                Text("Unit")
                    .font(.largeTitle.weight(.semibold))
                Spacer()
            }
            .frame(height: 60)
            Picker("Unit", selection: self.$model.unit) {
                ForEach(📏Unit.allCases) {
                    Text($0.value.symbol)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 360)
        }
    }
}
