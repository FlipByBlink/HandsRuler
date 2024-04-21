//MARK: iOS, iPadOS, Mac Catalyst, visionOS

import SwiftUI

struct ℹ️AboutAppContent: View {
    var body: some View {
        📰AppStoreDescriptionSection()
            .navigationTitle(String(localized: "About App", table: "🌐AboutApp"))
        📜VersionHistoryLink()
        👤PrivacyPolicySection()
        🏬AppStoreSection()
        📓SourceCodeLink()
        🧑‍💻AboutDeveloperPublisherLink()
        📧FeedbackLink()
    }
}

struct ℹ️IconAndName: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(.aboutAppIcon)
                    .resizable()
                    .frame(width: 100, height: 100)
                VStack(spacing: 6) {
                    Text(🗒️StaticInfo.appName)
                        .font(.system(.headline, design: .rounded))
                        .lineLimit(1)
                        .tracking(1.5)
                        .opacity(0.75)
                    Text(🗒️StaticInfo.appSubTitle)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .minimumScaleFactor(0.6)
            }
            .padding(32)
            Spacer()
        }
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
    }
}

struct ℹ️AppStoreLink: View {
    @Environment(\.openURL) var openURL
    var body: some View {
        Button {
            self.openURL(🗒️StaticInfo.appStoreProductURL)
        } label: {
            LabeledContent {
                Image(systemName: "arrow.up.forward.app")
            } label: {
                Label(String(localized: "Open App Store page", table: "🌐AboutApp"),
                      systemImage: "link")
            }
        }
    }
}

private struct 📰AppStoreDescriptionSection: View {
    var body: some View {
        Section {
            NavigationLink {
                ScrollView {
                    Text("current", tableName: "🌐AppStoreDescription")
                        .padding(Self.padding)
                        .frame(maxWidth: .infinity)
                }
                .navigationBarTitle(.init("Description", tableName: "🌐AboutApp"))
                .textSelection(.enabled)
            } label: {
                Text(self.textWithoutEmptyLines)
                    .font(.subheadline)
                    .lineSpacing(5)
                    .lineLimit(7)
                    .padding(8)
                    .accessibilityLabel(.init("Description", tableName: "🌐AboutApp"))
            }
        } header: {
            Text("Description", tableName: "🌐AboutApp")
        }
    }
    private static var padding: Double {
#if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16
#elseif os(visionOS)
        40
#endif
    }
    private var textWithoutEmptyLines: String {
        String(localized: "current", table: "🌐AppStoreDescription")
            .replacingOccurrences(of: "\n\n", with: "\n")
            .replacingOccurrences(of: "\n\n", with: "\n")
    }
}

private struct 🏬AppStoreSection: View {
    @Environment(\.openURL) var openURL
    var body: some View {
        Section {
            ℹ️AppStoreLink()
            Button {
                self.openURL(🗒️StaticInfo.appStoreUserReviewURL)
            } label: {
                LabeledContent {
                    Image(systemName: "arrow.up.forward.app")
                } label: {
                    Label(String(localized: "Review on App Store", table: "🌐AboutApp"),
                          systemImage: "star.bubble")
                }
            }
        } footer: {
            Text(verbatim: "\(🗒️StaticInfo.appStoreProductURL)")
        }
    }
}

private struct 👤PrivacyPolicySection: View {
    var body: some View {
        Section {
            NavigationLink {
                ScrollView {
                    Text(🗒️StaticInfo.privacyPolicyDescription)
                        .padding(Self.padding)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity)
                }
                .navigationTitle(.init("Privacy Policy", tableName: "🌐AboutApp"))
            } label: {
                Label(String(localized: "Privacy Policy", table: "🌐AboutApp"),
                      systemImage: "person.text.rectangle")
            }
        }
    }
    private static var padding: Double {
#if os(iOS)
        UIDevice.current.userInterfaceIdiom == .pad ? 32 : 24
#elseif os(visionOS)
        40
#endif
    }
}

private struct 📜VersionHistoryLink: View {
    var body: some View {
        Section {
            NavigationLink {
                List {
                    ForEach(🗒️StaticInfo.versionInfos, id: \.version) { ⓘnfo in
                        Section {
                            Text(LocalizedStringKey(ⓘnfo.version), tableName: "🌐VersionHistory")
                                .font(.subheadline)
                                .padding()
                                .textSelection(.enabled)
                        } header: {
                            Text(ⓘnfo.version)
                        } footer: {
                            if 🗒️StaticInfo.versionInfos.first?.version == ⓘnfo.version {
                                Text("builded on \(ⓘnfo.date)", tableName: "🌐AboutApp")
                            } else {
                                Text("released on \(ⓘnfo.date)", tableName: "🌐AboutApp")
                            }
                        }
                        .headerProminence(.increased)
                    }
                }
                .navigationBarTitle(.init("Version History", tableName: "🌐AboutApp"))
            } label: {
                Label(String(localized: "Version", table: "🌐AboutApp"),
                      systemImage: "signpost.left")
                .badge(🗒️StaticInfo.versionInfos.first?.version ?? "🐛")
            }
            .accessibilityLabel(.init("Version History", tableName: "🌐AboutApp"))
        }
    }
}

private var 📓sourceCodeFolderURL: URL {
#if targetEnvironment(macCatalyst)
    Bundle.main.bundleURL.appendingPathComponent("Contents/Resources/📁SourceCode")
#else
    Bundle.main.bundleURL.appendingPathComponent("📁SourceCode")
#endif
}

private struct 📓SourceCodeLink: View {
    var body: some View {
        NavigationLink {
            List {
                Self.DebugView()
                ForEach(🗒️StaticInfo.SourceCodeCategory.allCases) { Self.CodeSection($0) }
                Self.bundleMainInfoDictionary()
                Self.RepositoryLinks()
            }
            .navigationTitle(.init("Source code", tableName: "🌐AboutApp"))
        } label: {
            Label(String(localized: "Source code", table: "🌐AboutApp"),
                  systemImage: "doc.plaintext")
        }
    }
    private struct DebugView: View {
        private var fileCounts: Int? {
            try? FileManager.default
                .contentsOfDirectory(atPath: 📓sourceCodeFolderURL.path(percentEncoded: false))
                .count
        }
        private var caseCounts: Int {
            🗒️StaticInfo.SourceCodeCategory.allCases.reduce(into: 0) { $0 += $1.fileNames.count }
        }
        var body: some View {
            if let fileCounts {
                if fileCounts != self.caseCounts {
                    Section {
                        Text(verbatim: "⚠️ mismatch fileCounts")
                        LabeledContent(String("fileCounts"),
                                       value: self.fileCounts.debugDescription)
                        LabeledContent(String("caseCounts"),
                                       value: self.caseCounts.description)
                    }
                }
            } else {
                Text(verbatim: "⚠️ contentsOfDirectory failure")
            }
        }
    }
    private struct CodeSection: View {
        private var category: 🗒️StaticInfo.SourceCodeCategory
        var body: some View {
            Section {
                ForEach(self.category.fileNames, id: \.self) { ⓕileName in
                    let ⓤrl = 📓sourceCodeFolderURL.appendingPathComponent(ⓕileName)
                    if let ⓒode = try? String(contentsOf: ⓤrl) {
                        NavigationLink(ⓕileName) { self.sourceCodeView(ⓒode, ⓕileName) }
                    } else {
                        Text(verbatim: "🐛")
                    }
                }
                if self.category.fileNames.isEmpty { Text(verbatim: "🐛") }
            } header: {
                Text(self.category.rawValue)
                    .textCase(.none)
            }
        }
        init(_ category: 🗒️StaticInfo.SourceCodeCategory) {
            self.category = category
        }
        private func sourceCodeView(_ ⓣext: String, _ ⓣitle: String) -> some View {
            ScrollView {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(ⓣext)
                        .padding()
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .navigationBarTitle(LocalizedStringKey(ⓣitle))
            .font(.caption.monospaced())
            .textSelection(.enabled)
        }
    }
    private static func bundleMainInfoDictionary() -> some View {
        Section {
            NavigationLink(String("Bundle.main.infoDictionary")) {
                List {
                    if let ⓓictionary = Bundle.main.infoDictionary {
                        ForEach(ⓓictionary.map({$0.key}).sorted(), id: \.self) {
                            LabeledContent($0, value: String(describing: ⓓictionary[$0] ?? "🐛"))
                        }
                    }
                }
                .navigationBarTitle(.init(verbatim: "Bundle.main.infoDictionary"))
                .textSelection(.enabled)
            }
        }
    }
    private struct RepositoryLinks: View {
        @Environment(\.openURL) var openURL
        var body: some View {
            Section {
                Button {
                    self.openURL(🗒️StaticInfo.webRepositoryURL)
                } label: {
                    LabeledContent {
                        Image(systemName: "arrow.up.forward.app")
                    } label: {
                        Label(String(localized: "Web Repository", table: "🌐AboutApp"),
                              systemImage: "link")
                    }
                }
            } footer: {
                Text(verbatim: "\(🗒️StaticInfo.webRepositoryURL)")
            }
            Section {
                Button {
                    self.openURL(🗒️StaticInfo.webMirrorRepositoryURL)
                } label: {
                    LabeledContent {
                        Image(systemName: "arrow.up.forward.app")
                    } label: {
                        HStack {
                            Label(String(localized: "Web Repository", table: "🌐AboutApp"),
                                  systemImage: "link")
                            Text("(Mirror)", tableName: "🌐AboutApp")
                                .font(.subheadline.bold())
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } footer: {
                Text(verbatim: "\(🗒️StaticInfo.webMirrorRepositoryURL)")
            }
        }
    }
}

private struct 🧑‍💻AboutDeveloperPublisherLink: View {
    var body: some View {
        NavigationLink {
            List {
                Section {
                    LabeledContent {
                        Text("only one person", tableName: "🌐AboutApp")
                    } label: {
                        Text("Individual", tableName: "🌐AboutApp")
                    }
                } header: {
                    Text("The System", tableName: "🌐AboutApp")
                }
                Section {
                    LabeledContent(String("山下 亮"), value: "Yamashita Ryo")
                        .modifier(Self.TypeSettingLanguage())
                } header: {
                    Text("Name", tableName: "🌐AboutApp")
                }
                Section {
                    Text("age", tableName: "🌐AboutApp")
                        .badge(Text("about 29", tableName: "🌐AboutApp"))
                    Text("country", tableName: "🌐AboutApp")
                        .badge(Text("Japan", tableName: "🌐AboutApp"))
                    Text("native language", tableName: "🌐AboutApp")
                        .badge(Text("Japanese", tableName: "🌐AboutApp"))
                } header: {
                    Text("background", tableName: "🌐AboutApp")
                } footer: {
                    Text("As of 2023", tableName: "🌐AboutApp")
                }
                Self.TimelineSection()
                Section {
                    Image(.developerPublisher)
                        .resizable()
                        .frame(width: 90, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding()
                        .opacity(0.6)
                } header: {
                    Text("Image", tableName: "🌐AboutApp")
                } footer: {
                    Text("Taken on 2021-11", tableName: "🌐AboutApp")
                }
                Self.jobHuntSection()
            }
            .navigationTitle(.init("Developer / Publisher", tableName: "🌐AboutApp"))
        } label: {
            Label(String(localized: "Developer / Publisher", table: "🌐AboutApp"),
                  systemImage: "person")
        }
    }
    private struct TypeSettingLanguage: ViewModifier {
        func body(content: Content) -> some View {
            if #available(iOS 17.0, *) {
                content.typesettingLanguage(.init(languageCode: .japanese))
            } else {
                content
            }
        }
    }
    private struct TimelineSection: View {
        private static var localizedStringResources: [LocalizedStringResource] {
            [
                .init("2013-04", table: "🌐Timeline"),
                .init("2018-06", table: "🌐Timeline"),
                .init("2019-01", table: "🌐Timeline"),
                .init("2019-03", table: "🌐Timeline"),
                .init("2019-05", table: "🌐Timeline"),
                .init("2019-07", table: "🌐Timeline"),
                .init("2021-12", table: "🌐Timeline"),
                .init("2022-02", table: "🌐Timeline"),
                .init("2022-04", table: "🌐Timeline"),
                .init("2022-05", table: "🌐Timeline"),
                .init("2022-06", table: "🌐Timeline"), //two lines
                .init("2022-09", table: "🌐Timeline"),
                .init("2023-02", table: "🌐Timeline"),
                .init("2023-04", table: "🌐Timeline"),
                .init("2023-05", table: "🌐Timeline"),
                .init("2024-02", table: "🌐Timeline"),
            ]
        }
        var body: some View {
            Section {
                ForEach(Self.localizedStringResources, id: \.self.key) { ⓡesource in
                    HStack {
                        Text(ⓡesource.key)
                            .font(.caption2.monospacedDigit())
                            .padding(8)
                        Text(ⓡesource)
                            .font(.caption)
                    }
                }
            } header: {
                Text("Timeline", tableName: "🌐AboutApp")
            }
        }
    }
    private static func jobHuntSection() -> some View {
        Section {
            VStack(spacing: 8) {
                Text("Job hunting now!", tableName: "🌐AboutApp")
                    .font(.headline.italic())
                Text("If you are interested in hiring or acquiring, please contact me.",
                     tableName: "🌐AboutApp")
                .font(.subheadline)
                Text(🗒️StaticInfo.contactAddress)
                    .textSelection(.enabled)
                    .italic()
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity)
        }
    }
}

private struct 📧FeedbackLink: View {
    var body: some View {
        Section {
            NavigationLink {
                Self.Destination()
            } label: {
                Label(String(localized: "Feedback", table: "🌐AboutApp"),
                      systemImage: "envelope")
            }
        }
    }
    private struct Destination: View {
        @State private var copied: Bool = false
        @Environment(\.openURL) var openURL
        var body: some View {
            List {
                Section {
                    Button {
                        var ⓤrlString = "mailto:" + 🗒️StaticInfo.contactAddress
                        ⓤrlString += "?subject="
                        let ⓣitle = String(localized: 🗒️StaticInfo.appName)
                        ⓤrlString += ⓣitle
                        ⓤrlString += String(localized: " feedback", table: "🌐AboutApp")
                        ⓤrlString += "&body="
                        ⓤrlString += String(localized: "(Input here)", table: "🌐AboutApp")
                        self.openURL(.init(string: ⓤrlString)!)
                    } label: {
                        Label(String(localized: "Feedback from mail app", table: "🌐AboutApp"),
                              systemImage: "envelope")
                        .badge(Text(Image(systemName: "arrow.up.forward.app")))
                    }
                    VStack {
                        HStack {
                            Spacer()
                            Text(🗒️StaticInfo.contactAddress)
                                .textSelection(.enabled)
                                .italic()
                            Spacer()
                        }
                        Button(String(localized: "Copy", table: "🌐AboutApp")) {
                            UIPasteboard.general.string = 🗒️StaticInfo.contactAddress
                            withAnimation { self.copied = true }
                        }
                        .opacity(self.copied ? 0.3 : 1)
                        .buttonStyle(.bordered)
                        .overlay {
                            if self.copied {
                                Image(systemName: "checkmark")
                                    .bold()
                            }
                        }
                    }
                    .padding(.vertical)
                } footer: {
                    Text("bug report, feature request, impression...", tableName: "🌐AboutApp")
                }
            }
            .navigationBarTitle(String(localized: "Feedback", table: "🌐AboutApp"))
        }
    }
}
