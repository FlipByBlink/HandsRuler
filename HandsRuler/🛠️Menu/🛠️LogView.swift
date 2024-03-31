import SwiftUI

struct 🛠️LogView: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        List {
            Section {
                ForEach(self.logs.elements) { log in
                    LabeledContent {
                        Text(log.date, style: .offset)
                            .monospacedDigit()
                    } label: {
                        Label {
                            Text(🪧ResultModel(log.lineLength, self.model.unit).label)
                                .textSelection(.enabled)
                                .padding(.horizontal)
                        } icon: {
                            Image(systemName: "circle.and.line.horizontal")
                                .rotationEffect(.radians(log.rotationRadians))
                        }
                    }
                }
                .onDelete { self.logs.remove($0) }
                if self.logs.elements.isEmpty {
                    Text("empty")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.tertiary)
                }
            } header: {
                Text("Log")
            }
        }
        .animation(.default, value: self.logs.elements)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    💾Logs.clear()
                } label: {
                    Label("Clear", systemImage: "trash")
                        .padding(12)
                }
                .buttonStyle(.plain)
                .disabled(self.logs.elements.isEmpty)
                .animation(.default, value: self.logs.elements.isEmpty)
            }
        }
    }
}

private extension 🛠️LogView {
    private var logs: 💾Logs { .load(self.model.logsData) }
}
