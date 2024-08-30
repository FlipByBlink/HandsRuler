enum 🎚️Mode {
    case normal,
         raycast
}

extension 🎚️Mode: CaseIterable, Identifiable {
    var id: Self { self }
}
