import SwiftUI
import RealityKit
import ARKit

@MainActor
class 🥽AppModel: ObservableObject {
    @AppStorage("unit") var unit: 📏Unit = .meters
    @AppStorage("showInch") var showInchWithFeet: Bool = false
    @AppStorage("smallUnitWithYard") var smallUnitWithYard: 📏SmallUnitWithYard = .none
    @Published private(set) var authorizationStatus: ARKitSession.AuthorizationStatus?
    @Published var presentPanel: 🛠️Panel? = nil
    @Published var selectedLeft: Bool = false
    @Published var selectedRight: Bool = false
    
    private let session = ARKitSession()
    private let handTracking = HandTrackingProvider()
    
    let rootEntity = Entity()
    private let lineEntity = 🧩Entity.line()
    private let fingerEntities: [HandAnchor.Chirality: Entity] = 🧩Entity.fingerTips()
    
    private let sound1: AudioFileResource = try! .load(named: "sound1")
    private let sound2: AudioFileResource = try! .load(named: "sound2")
    
    private var coolDownSelection: Bool = false
}

extension 🥽AppModel {
    func setUpChildEntities() {
        self.rootEntity.addChild(self.lineEntity)
        self.fingerEntities.values.forEach { self.rootEntity.addChild($0) }
    }
    
    func changeSelection(_ targetedEntity: Entity) {
        guard !self.coolDownSelection else { return }
        switch targetedEntity.name {
            case 🧩Name.fingerLeft:
                self.selectedLeft.toggle()
                self.fingerEntities[.left]?.components.set(🧩Model.fingerTip(self.selectedLeft))
                let player = targetedEntity.prepareAudio(self.selectedLeft ? self.sound1 : self.sound2)
                player.gain = -8
                player.play()
            case 🧩Name.fingerRight:
                self.selectedRight.toggle()
                self.fingerEntities[.right]?.components.set(🧩Model.fingerTip(self.selectedRight))
                let player = targetedEntity.prepareAudio(self.selectedRight ? self.sound1 : self.sound2)
                player.gain = -8
                player.play()
            default:
                assertionFailure()
                break
        }
        Task {
            self.coolDownSelection = true
            try? await Task.sleep(for: .seconds(1))
            self.coolDownSelection = false
        }
    }
    
    var resultText: String {
        let measurement = Measurement(value: .init(self.lineLength), unit: UnitLength.meters)
        switch self.unit {
            case .centiMeters, .meters, .inches:
                let formatter = MeasurementFormatter()
                formatter.unitOptions = .providedUnit
                formatter.numberFormatter.maximumFractionDigits = {
                    switch self.unit {
                        case .centiMeters, .inches: 1
                        case .meters: 2
                        default: fatalError()
                    }
                }()
                return formatter.string(from: measurement.converted(to: self.unit.value))
            case .feet:
                if self.showInchWithFeet {
                    let feetFormatter = MeasurementFormatter()
                    feetFormatter.unitOptions = .providedUnit
                    feetFormatter.numberFormatter.maximumFractionDigits = 0
                    let inchFormatter = MeasurementFormatter()
                    inchFormatter.unitOptions = .providedUnit
                    inchFormatter.numberFormatter.maximumFractionDigits = 1
                    let feetValue = measurement.converted(to: .feet).value
                    let rounded = feetValue.rounded(.towardZero)
                    let feetPart = Measurement(value: rounded, unit: UnitLength.feet)
                    let inchPart = Measurement(value: feetValue - rounded, unit: UnitLength.feet).converted(to: .inches)
                    return ("\(feetFormatter.string(from: feetPart)) \(inchFormatter.string(from: inchPart))")
                } else {
                    let formatter = MeasurementFormatter()
                    formatter.unitOptions = .providedUnit
                    formatter.numberFormatter.maximumFractionDigits = 2
                    return formatter.string(from: measurement.converted(to: self.unit.value))
                }
            case .yards:
                return "placeholder"
        }
    }
    
    var labelFontSize: Double {
        self.lineLength < 1.2 ? 24 : 42
    }
    
    func observeAuthorizationStatus() {
        Task {
            self.authorizationStatus = await self.session.queryAuthorization(for: [.handTracking])[.handTracking]
            
            for await update in self.session.events {
                if case .authorizationChanged(let type, let status) = update {
                    if type == .handTracking { self.authorizationStatus = status }
                } else {
                    print("Another session event \(update).")
                }
            }
        }
    }
    
    func run() {
#if targetEnvironment(simulator)
        print("Not support handTracking in simulator.")
#else
        Task { @MainActor in
            do {
                try await self.session.run([self.handTracking])
                await self.processHandUpdates()
            } catch {
                print(error)
            }
        }
#endif
    }
}

fileprivate extension 🥽AppModel {
    private func processHandUpdates() async {
        for await update in self.handTracking.anchorUpdates {
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked,
                  let fingerTip = handAnchor.handSkeleton?.joint(.indexFingerTip),
                  fingerTip.isTracked else {
                continue
            }
            
            if self.selectedLeft, handAnchor.chirality == .left { continue }
            if self.selectedRight, handAnchor.chirality == .right { continue }
            
            let originFromWrist = handAnchor.originFromAnchorTransform
            
            let wristFromIndex = fingerTip.anchorFromJointTransform
            let originFromIndex = originFromWrist * wristFromIndex
            self.fingerEntities[handAnchor.chirality]?.setTransformMatrix(originFromIndex,
                                                                          relativeTo: nil)
            
            self.updateLine()
            self.updateResultLabelPosition()
        }
    }
    
    private func updateLine() {
        self.lineEntity.position = self.centerPosition
        self.lineEntity.components.set(🧩Model.line(self.lineLength))
        self.lineEntity.look(at: self.leftPosition,
                             from: self.centerPosition,
                             relativeTo: nil)
    }
    
    private func updateResultLabelPosition() {
        self.rootEntity.findEntity(named: 🌐RealityView.attachmentID)?
            .position = self.centerPosition
    }
    
    private var lineLength: Float {
        distance(self.leftPosition, self.rightPosition)
    }
    
    private var centerPosition: SIMD3<Float> {
        (self.leftPosition + self.rightPosition) / 2
    }
    
    private var leftPosition: SIMD3<Float> {
        self.fingerEntities[.left]?.position ?? .zero
    }
    
    private var rightPosition: SIMD3<Float> {
        self.fingerEntities[.right]?.position ?? .zero
    }
}




//MARK: Simulator
extension 🥽AppModel {
    func setUp_simulator() {
#if targetEnvironment(simulator)
        self.updateLine()
        self.updateResultLabelPosition()
#endif
    }
    func setRandomPosition_simulator() {
#if targetEnvironment(simulator)
        if !self.selectedLeft {
            self.fingerEntities[.left]?.position = .init(x: .random(in: -0.8 ..< -0.05),
                                                         y: .random(in: 1 ..< 1.5),
                                                         z: .random(in: -1 ..< -0.5))
        }
        if !self.selectedRight {
            self.fingerEntities[.right]?.position = .init(x: .random(in: 0.05 ..< 0.8),
                                                          y: .random(in: 1 ..< 1.5),
                                                          z: .random(in: -1 ..< -0.5))
        }
        self.updateLine()
        self.updateResultLabelPosition()
#endif
    }
}
