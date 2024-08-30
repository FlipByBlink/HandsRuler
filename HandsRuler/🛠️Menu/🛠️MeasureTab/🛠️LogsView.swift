import SwiftUI

struct 🛠️LogsView: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        List {
            Section {
                ForEach(self.model.logs.elements, id: \.worldAnchorID) {
                    self.logView($0)
                }
                .onDelete { self.model.removeLog($0) }
                if self.model.logs.elements.isEmpty { Self.emptyStateView() }
            } header: {
                Text("Log")
            }
        }
        .animation(.default, value: self.model.logs.elements)
        .toolbar { self.clearButton() }
    }
}

private extension 🛠️LogsView {
    private func logView(_ log: 💾Log) -> some View {
        LabeledContent {
            HStack(spacing: 12) {
                TimelineView(.periodic(from: .now, by: 1)) { _ in
                    Text(
                        RelativeDateTimeFormatter()
                            .localizedString(for: log.date, relativeTo: .now)
                    )
                    .monospacedDigit()
                }
                Menu {
                    Button {
                        UIPasteboard.general.string = 🧾ResultFormatter.string(log.lineLength,
                                                                               self.model.unit)
                    } label: {
                        Label("Copy as text", systemImage: "doc.on.doc")
                    }
                    Button(role: .destructive) {
                        self.model.removeLog(log)
                    } label: {
                        Label("Remove", systemImage: "delete.left")
                    }
                } label: {
                    Label("Menu", systemImage: "ellipsis.circle")
                        .padding(2)
                }
                .padding(6)
                .foregroundStyle(.secondary)
                .labelStyle(.iconOnly)
                .buttonStyle(.plain)
            }
        } label: {
            Label {
                Text(🧾ResultFormatter.string(log.lineLength, self.model.unit))
                    .textSelection(.enabled)
                    .monospacedDigit()
                    .padding(.horizontal)
            } icon: {
                Image(systemName: "circle.and.line.horizontal")
                    .rotationEffect(.radians(-log.rotationRadians))
            }
        }
    }
    private func clearButton() -> some ToolbarContent {
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
    private static func emptyStateView() -> some View {
        Text("empty")
            .frame(maxWidth: .infinity)
            .foregroundStyle(.tertiary)
    }
}
