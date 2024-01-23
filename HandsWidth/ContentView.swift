import SwiftUI

struct ContentView: View {
    @StateObject var model: 🥽AppModel = .init()
    var body: some View {
        🌐RealityView()
            .background { 🛠️MenuTop() }
            .environmentObject(self.model)
    }
}
