import SwiftUI

struct ContentView: View {
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                HStack(spacing: 28) {
                    Image(.graph1)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300)
                        .clipShape(.rect(cornerRadius: 16, style: .continuous))
                    Image(.graph2)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300)
                        .clipShape(.rect(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 8)
                Spacer()
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
                Spacer()
            }
            .navigationTitle("HandsRuler")
            .toolbar {
                NavigationLink {
                    List {
                        ℹ️AboutAppContent()
                    }
                } label: {
                    Label("About App", systemImage: "info")
                        .padding(14)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.plain)
            }
        }
        .frame(width: 700, height: 450)
    }
}
