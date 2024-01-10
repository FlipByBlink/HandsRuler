import SwiftUI
import RealityKit
import ARKit

struct 👆MeasureView: View {
    @EnvironmentObject var model: 📱AppModel
    @State private var rootEntity: Entity?
    var body: some View {
        RealityView { content, _ in
        } update: { content, attachments in
        } attachments: {
            Attachment(id: "Attachment") {
                Text("placeholder")
                    .font(.system(size: 54).bold())
                    .padding(24)
                    .glassBackgroundEffect()
            }
        }
        .onTapGesture {}
    }
}
