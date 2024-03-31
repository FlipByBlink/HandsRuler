import Foundation

struct 💾Logs: Codable {
    private(set) var elements: [💾Log]
}

extension 💾Logs {
    static func load(_ data: Data?) -> Self {
        if let data {
            try! JSONDecoder().decode(Self.self, from: data)
        } else {
            .init(elements: [])
        }
    }
    static var current: Self { .load(UserDefaults.standard.data(forKey: "logsData")) }
    func add(_ newElement: 💾Log) {
        var newValue = self
        newValue.elements.insert(newElement, at: 0)
        Self.save(newValue)
    }
    func remove(_ indexSet: IndexSet) {
        var newValue = self
        newValue.elements.remove(atOffsets: indexSet)
        Self.save(newValue)
    }
    func remove(_ log: 💾Log) {
        var newValue = self
        newValue.elements.removeAll { $0 == log }
        Self.save(newValue)
    }
    static func clear() {
        Self.save(Self(elements: []))
    }
}

private extension 💾Logs {
    private static func save(_ newValue: Self) {
        UserDefaults.standard.setValue(try! JSONEncoder().encode(newValue),
                                       forKey: "logsData")
    }
}
