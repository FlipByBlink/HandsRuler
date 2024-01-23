import SwiftUI

struct 🛠️AboutPanel: View {
    @EnvironmentObject var model: 🥽AppModel
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Text("About HandsWidth")
                    .font(.largeTitle.weight(.semibold))
                Spacer()
            }
            .frame(height: 60)
            HStack(spacing: 32) {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 300, height: 200)
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 300, height: 200)
            }
            .padding(.horizontal)
            Button {
                
            } label: {
                Text("Start")
                    .font(.system(size: 36))
                    .padding()
            }
            .padding()
            .frame(minHeight: 60)
        }
    }
}
