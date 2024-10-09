# Sample code: minimal version

![Example](https://flipbyblink.github.io/HandsRuler/HandsRuler/Supporting%20files/Rest/Sample%20code/images/Example.jpg)


## Outline
- Measure the distance between the tips of the index fingers of both hands.
- Displays a 3D object of the tape measure.
- Displays the measured value at the center of the tape measure.
- The unit is meters.


## Source code
```swift
import SwiftUI
import RealityKit
import ARKit

@main
struct MyApp: App {
    @StateObject private var model = AppModel()
    var body: some SwiftUI.Scene {
        ImmersiveSpace {
            RealityView { content, attachments in
                content.add(model.myEntities.root)
                model.myEntities.add(attachments.entity(for: "resultBoard")!)
            } attachments: {
                Attachment(id: "resultBoard") {
                    Text(model.resultString)
                        .monospacedDigit()
                        .padding()
                        .glassBackgroundEffect()
                        .offset(y: -80)
                }
            }
            .task { await model.runSession() }
            .task { await model.processAnchorUpdates() }
        }
    }
}

@MainActor
class AppModel: ObservableObject {
    private var arKitSession = ARKitSession()
    private var handTrackingProvider = HandTrackingProvider()
    @Published var resultString: String = ""
    let myEntities = MyEntities()
    
    func runSession() async {
        try! await arKitSession.run([handTrackingProvider])
    }
    
    func processAnchorUpdates() async {
        for await update in handTrackingProvider.anchorUpdates {
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked,
                  let joint = handAnchor.handSkeleton?.joint(.indexFingerTip),
                  joint.isTracked else {
                continue
            }
            
            let originFromWrist = handAnchor.originFromAnchorTransform
            
            let wristFromIndex = joint.anchorFromJointTransform
            let originFromIndex = originFromWrist * wristFromIndex
            
            let fingerTipEntity = myEntities.fingerTips[handAnchor.chirality]
            fingerTipEntity?.setTransformMatrix(originFromIndex, relativeTo: nil)
            
            myEntities.update()
            resultString = myEntities.getResultString()
        }
    }
}

@MainActor
class MyEntities {
    let root = Entity()
    let fingerTips: [HandAnchor.Chirality: Entity]
    let line = Entity()
    var resultBoard: Entity?
    
    init() {
        fingerTips = [
            .left: ModelEntity(mesh: .generateSphere(radius: 0.01), materials: [SimpleMaterial()]),
            .right: ModelEntity(mesh: .generateSphere(radius: 0.01), materials: [SimpleMaterial()])
        ]
        fingerTips.values.forEach { root.addChild($0) }
        
        line.components.set(OpacityComponent(opacity: 0.75))
        
        root.addChild(line)
    }
    
    func add(_ resultBoardEntity: Entity) {
        resultBoard = resultBoardEntity
        root.addChild(resultBoardEntity)
    }
    
    func update() {
        let centerPosition = (fingerTips[.left]!.position + fingerTips[.right]!.position) / 2
        let length = distance(fingerTips[.left]!.position, fingerTips[.right]!.position)
        
        line.position = centerPosition
        line.components.set(ModelComponent(mesh: .generateBox(width: 0.01,
                                                              height: 0.01,
                                                              depth: length,
                                                              cornerRadius: 0.005),
                                           materials: [SimpleMaterial()]))
        line.look(at: fingerTips[.left]!.position, from: centerPosition, relativeTo: nil)
        
        resultBoard?.setPosition(centerPosition, relativeTo: nil)
    }
    
    func getResultString() -> String {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.minimumFractionDigits = 2
        formatter.numberFormatter.maximumFractionDigits = 2
        let length = distance(fingerTips[.left]!.position, fingerTips[.right]!.position)
        return formatter.string(from: .init(value: .init(length), unit: UnitLength.meters))
    }
}
```

That is all the source code. Please copy and paste.


## Additional work
- Set a text to "NSSHandsTrackingUsageDescription" in Info.plist
- Set "Immersive Space" to "Preferred Default Scene Session Role" in Info.plist

![Info.plist Screenshot](https://flipbyblink.github.io/HandsRuler/HandsRuler/Supporting%20files/Rest/Sample%20code/images/Info.plist%20Screenshot.png)


## Description
Basic information about SwiftUI, RealityKit and ARKit is omitted.

### Types
```swift
@main
struct MyApp: App { ... }

class AppModel: ObservableObject { ... }

class MyEntities { ... }
```

The code is implemented in three parts: "SwittUI's Scene and View", "App Model" and "RealityKit's Entities".

### Hands tracking
```swift
class AppModel: ObservableObject {
    private var arKitSession = ARKitSession()
    private var handTrackingProvider = HandTrackingProvider()
    @Published var resultString: String = ""
    let myEntities = MyEntities()
    
    func runSession() async {
        try! await arKitSession.run([handTrackingProvider])
    }
    
    func processAnchorUpdates() async {
        for await update in handTrackingProvider.anchorUpdates {
            let handAnchor = update.anchor
            
            guard handAnchor.isTracked,
                  let joint = handAnchor.handSkeleton?.joint(.indexFingerTip),
                  joint.isTracked else {
                continue
            }
            
            let originFromWrist = handAnchor.originFromAnchorTransform
            
            let wristFromIndex = joint.anchorFromJointTransform
            let originFromIndex = originFromWrist * wristFromIndex
            
            let fingerTipEntity = myEntities.fingerTips[handAnchor.chirality]
            fingerTipEntity?.setTransformMatrix(originFromIndex, relativeTo: nil)
            
            myEntities.update()
            resultString = myEntities.getResultString()
        }
    }
}
```

Receive a latest hand joint data from anchorUpdates of HandTrackingProvider. Next, the position data of the index finger tip is applied to the Entity. Next, other Entities and text are updated based on the position.

### The text is displayed in SwiftUI's View
```swift
RealityView { content, attachments in
    ...
    model.myEntities.add(attachments.entity(for: "resultBoard")!)
} attachments: {
    Attachment(id: "resultBoard") {
        Text(model.resultString)
            .monospacedDigit()
            .padding()
            .glassBackgroundEffect()
            .offset(y: -80)
    }
}
```

This app basically uses RealityKit's Entity to represent the look and feel. However, RealityKit's dynamic text display is poor, so I adopted SwiftUI's View for the text.

### Adjust text
```swift
Text(model.resultString)
    .monospacedDigit()
```

```swift
func getResultString() -> String {
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit
    formatter.numberFormatter.minimumFractionDigits = 2
    formatter.numberFormatter.maximumFractionDigits = 2
    let length = distance(fingerTips[.left]!.position, fingerTips[.right]!.position)
    return formatter.string(from: .init(value: .init(length), unit: UnitLength.meters))
}
```

The user experience will be very poor if the numerical values of the measurement results are displayed without adjustment. When the numerical values change, the entire text will be out of alignment, or the entire view will change size, making it difficult to read.

Therefore, I made the text easier to read by using a monospaced font with monospacedDigit and fixed the number of digits after the decimal point with MeasurementFormatter.


## Notice: Required actual device
Required an actual Apple Vision Pro device to try ARKit hand tracking. It does not work at all in the simulator.
