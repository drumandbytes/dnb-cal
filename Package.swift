// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DnbCal",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "DnbCal", path: "Sources/DnbCal"),
        .testTarget(name: "DnbCalTests", dependencies: ["DnbCal"], path: "Tests/DnbCalTests"),
    ]
)
