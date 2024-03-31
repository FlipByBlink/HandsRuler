import RealityKit

struct 📢Sounds {
    private let select: AudioFileResource = try! .load(named: "select")
    private let unselect: AudioFileResource = try! .load(named: "unselect")
    subscript(selected: Bool) -> AudioFileResource {
        selected ? self.select : self.unselect
    }
    
    let fix: AudioFileResource = try! .load(named: "fix")
}
