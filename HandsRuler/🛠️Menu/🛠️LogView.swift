import SwiftUI

struct 🛠️LogView: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        List {
            Section {
                ForEach(self.logs.elements) { log in
                    LabeledContent {
                        TimelineView(.periodic(from: .now, by: 1)) { _ in
                            Text(
                                RelativeDateTimeFormatter()
                                    .localizedString(for: log.date, relativeTo: .now)
                            )
                            .monospacedDigit()
                        }
                    } label: {
                        Label {
                            Text(🪧ResultFormatter.string(log.lineLength, self.model.unit))
                                .textSelection(.enabled)
                                .monospacedDigit()
                                .padding(.horizontal)
                        } icon: {
                            Image(systemName: "circle.and.line.horizontal")
                                .rotationEffect(.radians(-log.rotationRadians))
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
                    Image(systemName: "trash")
                        .padding(14)
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                .help("Clear")
                .disabled(self.logs.elements.isEmpty)
                .animation(.default, value: self.logs.elements.isEmpty)
            }
        }
    }
}

private extension 🛠️LogView {
    private var logs: 💾Logs { .load(self.model.logsData) }
}
