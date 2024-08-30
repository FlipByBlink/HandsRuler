import SwiftUI

struct 📏ResultBoardView: View {
    @EnvironmentObject var model: 🥽AppModel
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.1)) { _ in
            📏ResultBoardLabel(self.model.entities.currentLineLength)
        }
    }
}
