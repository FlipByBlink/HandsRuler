import Foundation

extension 🥽AppModel {
    func removeLog(_ log: 💾Log) {
        self.logs.remove(log)
        self.activeWorldAnchors.removeAll { $0.id == log.worldAnchorID }
        self.entities.removeFixedRuler(log.worldAnchorID)
        Task { try? await self.worldTrackingProvider.removeAnchor(forID: log.worldAnchorID) }
    }
    
    func removeLog(_ indexSet: IndexSet) {
        indexSet.forEach { self.removeLog(self.logs.elements[$0]) }
    }
    
    func clearLogs() {
        Task {
            for log in self.logs.elements {
                self.activeWorldAnchors.removeAll { $0.id == log.worldAnchorID }
                self.entities.removeFixedRuler(log.worldAnchorID)
                try? await self.worldTrackingProvider.removeAnchor(forID: log.worldAnchorID)
            }
            self.logs.clear()
        }
    }
}
