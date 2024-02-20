import SwiftUI

struct 🛠️SettingPanel: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Picker("Unit", selection: self.$model.unit) {
                    ForEach(📏Unit.allCases) {
                        Text($0.value.symbol)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 360)
                .padding(.bottom, 12)
                if self.model.unit == .feet {
                    Toggle("Show inch", isOn: self.$model.showInchWithFeet)
                        .padding(12)
                }
                Spacer()
            }
            .animation(.default, value: self.model.unit == .feet)
            .navigationTitle("Unit")
            .toolbar {
                Button {
                    self.model.presentPanel = nil
                } label: {
                    Image(systemName: "arrow.down.right.and.arrow.up.left")
                        .padding(8)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.plain)
            }
        }
        .frame(height: 280)
        .frame(width: 450)
    }
}
