import SwiftUI

enum 🗒️StaticInfo {
    static let appName: LocalizedStringResource = "HandsRuler"
    static var appSubTitle: LocalizedStringResource { "Apple Vision Pro" }
    
    static let appStoreProductURL: URL = .init(string: "https://apps.apple.com/app/id6475769879")!
    static var appStoreUserReviewURL: URL { .init(string: "\(Self.appStoreProductURL)?action=write-review")! }
    
    static var contactAddress: String { "dapper_glowing_0d@icloud.com" }
    
    static let privacyPolicyDescription = """
        2024-02-02
        
        
        English
        
        This application don't collect user infomation.
        
        
        日本語(Japanese)
        
        このアプリ自身において、ユーザーの情報を一切収集しません。
        """
    
    static let webRepositoryURL: URL = .init(string: "https://github.com/FlipByBlink/HandsRuler")!
    static let webMirrorRepositoryURL: URL = .init(string: "https://gitlab.com/FlipByBlink/HandsRuler_Mirror")!

    static let versionInfos: [(version: String, date: String)] = [("1.1.1", "2024-07-22"),
                                                                  ("1.1", "2024-04-26"),
                                                                  ("1.0.1", "2024-02-15"),
                                                                  ("1.0", "2024-02-02")] //降順。先頭の方が新しい
    
    enum SourceCodeCategory: String, CaseIterable, Identifiable {
        case main,
             AppModel,
             MeasureView,
             Entity,
             Menu,
             Rest
        var id: Self { self }
        var fileNames: [String] {
            switch self {
                case .main: [
                    "App.swift",
                    "ContentView.swift"
                ]
                case .AppModel: [
                    "🥽AppModel.swift",
                    "🥽userAction.swift",
                    "🥽arKit.swift",
                    "🥽updateRuler.swift",
                    "🥽rest.swift",
                    "🥽simulator.swift"
                ]
                case .MeasureView: [
                    "📏MeasureView.swift",
                    "📏ResultBoardView.swift"
                ]
                case .Entity: [
                    "🧩Entities.swift",
                    "🧩Entity.swift",
                    "🧩Model.swift"
                ]
                case .Menu: [
                    "🛠️MeasureTab.swift",
                    "🛠️OnboardView.swift",
                    "🛠️LogView.swift",
                    "🛠️OptionTab.swift",
                    "🛠️GuideTab.swift",
                    "🛠️RequestTab.swift",
                    "🛠️AboutTab.swift",
                    "🗒️StaticInfo.swift",
                    "ℹ️AboutApp.swift"
                ]
                case .Rest: [
                    "📐Unit.swift",
                    "🧾ResultFormatter.swift",
                    "🔵Selection.swift",
                    "📢Sounds.swift",
                    "🪧BillboardComponent.swift",
                    "🪧BillboardSystem.swift",
                    "💾Log.swift",
                    "💾Logs.swift"
                ]
            }
        }
    }
}
