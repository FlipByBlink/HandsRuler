import RealityKit

struct 📢Sounds {
    private let sound1: AudioFileResource = try! .load(named: "sound1")
    private let sound2: AudioFileResource = try! .load(named: "sound2")
    subscript(selected: Bool) -> AudioFileResource {
        selected ? self.sound1 : self.sound2
    }
}
