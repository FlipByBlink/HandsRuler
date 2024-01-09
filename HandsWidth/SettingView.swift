import SwiftUI

struct SettingView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    var body: some View {
        NavigationStack {
            List {
                Picker("Unit", selection: .constant("m")) {
                    Text("m")
                    Text("cm")
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
