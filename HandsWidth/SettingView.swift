import SwiftUI

struct SettingView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    var body: some View {
        NavigationStack {
            List {
                Picker("Unit", selection: self.$model.unit) {
                    ForEach(📏Unit.allCases) {
                        Text($0.rawValue)
                    }
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
            .animation(.default, value: self.model.presentImmersiveSpace)
        }
        .onChange(of: self.model.presentImmersiveSpace) { _, newValue in
            if newValue == false { self.dismissWindow() }
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
