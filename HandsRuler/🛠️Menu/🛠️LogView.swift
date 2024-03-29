import SwiftUI

struct 🛠️LogView: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        List {
            ForEach(self.model.logs, id: \.leftID) { log in
                LabeledContent {
                    Text(log.date, style: .offset)
                } label: {
                    Label {
                        Text(log.lineLength.formatted())
                    } icon: {
                        Image(systemName: "circle.and.line.horizontal")
                            .rotationEffect(.radians(log.rotationRadians))
                    }
                }
            }
        }
    }
}
