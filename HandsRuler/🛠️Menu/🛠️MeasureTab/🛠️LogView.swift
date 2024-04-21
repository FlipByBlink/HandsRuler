import SwiftUI

struct 🛠️LogView: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        List {
            Section {
                ForEach(self.model.logs.elements) { log in
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
                .onDelete { self.model.removeLog($0) }
                if self.model.logs.elements.isEmpty {
                    Text("empty")
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.tertiary)
                }
            } header: {
                Text("Log")
            }
        }
        .animation(.default, value: self.model.logs.elements)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    self.model.clearLogs()
                } label: {
                    Image(systemName: "trash")
                        .padding(14)
                }
                .buttonStyle(.plain)
                .buttonBorderShape(.circle)
                .help("Clear")
                .disabled(self.model.logs.elements.isEmpty)
                .animation(.default, value: self.model.logs.elements.isEmpty)
            }
        }
    }
}
