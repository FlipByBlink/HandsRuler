import ARKit

struct 💾Logs: Codable {
    private(set) var elements: [💾Log]
    private(set) var hasNeverLogged: Bool = true
}

extension 💾Logs: Equatable {
    subscript(worldAnchorID: UUID) -> 💾Log? {
        self.elements.first(where: { $0.worldAnchorID == worldAnchorID })
    }
    static func load() -> Self {
        if let data = UserDefaults.standard.data(forKey: "logsData"),
           let value = try? JSONDecoder().decode(Self.self, from: data) {
            value
        } else {
            Self(elements: [])
        }
    }
    var isEmpty: Bool { self.elements.isEmpty }
    mutating func add(_ newLog: 💾Log) {
        self.edit(.add(newLog))
    }
    mutating func remove(_ target: 💾Log) {
        self.edit(.remove(target))
    }
    mutating func clear() {
        self.edit(.clear)
    }
}

private extension 💾Logs {
    private mutating func edit(_ action: Action) {
        switch action {
            case .add(let newLog):
                self.elements.insert(newLog, at: 0)
            case .remove(let target):
                self.elements.removeAll { $0 == target }
            case .clear:
                self.elements.removeAll()
        }
        self.save()
        self.hasNeverLogged = false
    }
    private enum Action {
        case add(💾Log),
             remove(💾Log),
             clear
    }
    private func save() {
        UserDefaults.standard.setValue(try! JSONEncoder().encode(self),
                                       forKey: "logsData")
    }
}
