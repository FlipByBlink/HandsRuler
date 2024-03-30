import SwiftUI

struct 🛠️LogView: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        List {
            Section {
                if !self.logs.value.isEmpty {
                    ForEach(self.logs.value, id: \.leftID) { log in
                        LabeledContent {
                            Text(log.date, style: .offset)
                        } label: {
                            Label {
                                Text(log.lineLength.formatted())
                            } icon: {
                                Image(systemName: "circle.and.line.horizontal")
                                    .rotationEffect(.radians(log.rotationRadians))
                            }
                        }
                    }
                    .onDelete { self.logs.remove($0) }
                } else {
                    Text("empty")
                        .foregroundStyle(.tertiary)
                }
            } header: {
                Text("Log")
            }
        }
        .animation(.default, value: self.logs.value.isEmpty)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Set debug value") { 💾Logs.setDebugValue() }
                Button("Clear") { 💾Logs.clear() }
            }
        }
    }
}

private extension 🛠️LogView {
    private var logs: 💾Logs { .load(self.model.logsData) }
}
