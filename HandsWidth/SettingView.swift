import SwiftUI

struct SettingView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    var body: some View {
        NavigationStack {
            List {
                Picker("Unit", selection: self.$model.unit) {
                    ForEach(📏Unit.allCases) {
                        Text($0.rawValue)
                    }
                }
                Button("Start measure") {
                    Task {
                        await self.openImmersiveSpace(id: "measure")
                    }
                }
            }
            .font(.title)
            .navigationTitle("Setting")
        }
    }
}

enum 📏Unit: String, CaseIterable, Identifiable {
    case meters, centiMeters, inches
    var id: Self { self }
    var value: UnitLength {
        switch self {
            case .meters: .meters
            case .centiMeters: .centimeters
            case .inches: .inches
        }
    }
}
