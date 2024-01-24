import SwiftUI

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    var body: some View {
        VStack(spacing: 24) {
            Text("HandsWidth")
                .font(.largeTitle.weight(.semibold))
            HStack(spacing: 32) {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 300, height: 200)
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 300, height: 200)
            }
            Button {
                Task {
                    await self.openImmersiveSpace(id: "immersiveSpace")
                    self.dismissWindow()
                }
            } label: {
                Text("Start")
                    .font(.largeTitle)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 4)
            }
        }
        .padding(32)
    }
}
