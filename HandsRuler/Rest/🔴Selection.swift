enum 🔴Selection {
    case left,
         right,
         noSelect
}

extension 🔴Selection {
    var isLeft: Bool { self == .left }
    var isRight: Bool { self == .right }
}
