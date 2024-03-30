import SwiftUI

struct 🛠️LogView: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        List {
            Section {
                if !self.logs.elements.isEmpty {
                    ForEach(self.logs.elements) { log in
                        LabeledContent {
                            Text(log.date, style: .offset)
                        } label: {
                            Label {
                                Text(🪧ResultModel(log.lineLength, self.model.unit).label)
                            } icon: {
                                Image(systemName: "circle.and.line.horizontal")
                                    .rotationEffect(.radians(log.rotationRadians))
                            }
                        }
                    }
                    .onDelete { self.logs.remove($0) }
                } else {
                    Text("empty")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.tertiary)
                }
            } header: {
                Text("Log")
            }
        }
        .animation(.default, value: self.logs.elements.isEmpty)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button("Clear") { 💾Logs.clear() }
            }
        }
    }
}

private extension 🛠️LogView {
    private var logs: 💾Logs { .load(self.model.logsData) }
}
