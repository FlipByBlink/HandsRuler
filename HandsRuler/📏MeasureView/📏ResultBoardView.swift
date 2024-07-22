import SwiftUI

struct 📏ResultBoardView: View {
    @EnvironmentObject var model: 🥽AppModel
    private var lineLength: Float
    private var isFixedRuler: Bool
    var body: some View {
        Text(🧾ResultFormatter.string(self.lineLength, self.model.unit))
            .font(.system(size: CGFloat(max(min(self.lineLength * 32, 44), 20))))
            .fontWeight(.bold)
            .monospacedDigit()
            .padding(12)
            .padding(.horizontal, 4)
            .contentShape(.capsule)
            .hoverEffect(isEnabled: self.isFixedRuler)
            .glassBackgroundEffect()
            .onTapGesture(count: 2) { self.model.setRandomPosition_simulator() }
    }
    init(_ lineLength: Float, isFixedRuler: Bool = false) {
        self.lineLength = lineLength
        self.isFixedRuler = isFixedRuler
    }
}
