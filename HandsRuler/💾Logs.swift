import Foundation

struct 💾Logs: Codable {
    private(set) var value: [💾Log]
}

extension 💾Logs {
    static func load(_ data: Data?) -> Self {
        if let data {
            try! JSONDecoder().decode(Self.self, from: data)
        } else {
            .init(value: [])
        }
    }
    func add(_ newElement: 💾Log) {
        var newLogs = self
        newLogs.value.append(newElement)
        Self.save(newLogs)
    }
    func remove(_ indexSet: IndexSet) {
        var newLogs = self
        newLogs.value.remove(atOffsets: indexSet)
        Self.save(newLogs)
    }
    static func clear() {
        Self.save(Self(value: []))
    }
}

private extension 💾Logs {
    private static func save(_ newLogs: Self) {
        UserDefaults.standard.setValue(try! JSONEncoder().encode(newLogs),
                                       forKey: "logsData")
    }
}



//MARK: ==== For debug ====
extension 💾Logs {
    static func setDebugValue() {
        Self.save(Self(value: [.init(leftID: .init(),
                                     rightID: .init(),
                                     lineLength: 1,
                                     rotationRadians: 0.1,
                                     date: .now.addingTimeInterval(-20)),
                               .init(leftID: .init(),
                                     rightID: .init(),
                                     lineLength: 1.3,
                                     rotationRadians: 0.4,
                                     date: .now.addingTimeInterval(-100))]))
    }
}
