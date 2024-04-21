import SwiftUI

struct 🛠️OnboardView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(.graph1)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300)
                .clipShape(.rect(cornerRadius: 16, style: .continuous))
            Spacer()
            Image(.graph2)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300)
                .clipShape(.rect(cornerRadius: 16, style: .continuous))
            Spacer()
        }
    }
}
