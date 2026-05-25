// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FastNote",
    defaultLocalization: "en",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "FastNote",
            path: "FastNote",
            exclude: ["Info.plist", "Resources"]
        )
    ]
)
