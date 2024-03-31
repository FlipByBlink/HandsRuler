import RealityKit

struct 📢Sounds {
    let select: AudioFileResource = try! .load(named: "select")
    let unselect: AudioFileResource = try! .load(named: "unselect")
    let fix: AudioFileResource = try! .load(named: "fix")
}
