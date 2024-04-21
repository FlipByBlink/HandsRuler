import ARKit

struct 💾Logs: Codable {
    private(set) var elements: [💾Log]
    private(set) var hasNeverLogged: Bool = true
}

extension 💾Logs: Equatable {
    subscript(worldAnchorID: UUID) -> 💾Log? {
        self.elements.first(where: { $0.id == worldAnchorID })
    }
//    static func load(_ data: Data?) -> Self {
//        if let data {
//            try! JSONDecoder().decode(Self.self, from: data)
//        } else {
//            .init(elements: [])
//        }
//    }
//    static var current: Self { .load() }
    static func load() -> Self {
        if let data = UserDefaults.standard.data(forKey: "logsData"),
           let value = try? JSONDecoder().decode(Self.self, from: data) {
            value
        } else {
            Self(elements: [])
        }
    }
    var isEmpty: Bool { self.elements.isEmpty }
//    func add(_ newElement: 💾Log) {
//        var newValue = self
//        newValue.elements.insert(newElement, at: 0)
//        Self.save(newValue)
//    }
//    func remove(_ indexSet: IndexSet) {
//        var newValue = self
//        newValue.elements.remove(atOffsets: indexSet)
//        Self.save(newValue)
//    }
//    func remove(_ log: 💾Log) {
//        var newValue = self
//        newValue.elements.removeAll { $0 == log }
//        Self.save(newValue)
//    }
//    static func clear() {
//        Self.save(Self(elements: []))
//    }
    mutating func edit(_ action: Action) {
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
    enum Action {
        case add(newElement: 💾Log),
             remove(💾Log),
             clear
    }
}

private extension 💾Logs {
    private func save() {
        UserDefaults.standard.setValue(try! JSONEncoder().encode(self),
                                       forKey: "logsData")
    }
}
