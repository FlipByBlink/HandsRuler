import SwiftUI

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    var body: some View {
        VStack(spacing: 32) {
            Text("HandsWidth")
                .font(.largeTitle.weight(.semibold))
            HStack(spacing: 28) {
                Image(.graph1)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300)
                    .clipShape(.rect(cornerRadius: 24))
                Image(.graph2)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300)
                    .clipShape(.rect(cornerRadius: 24))
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
