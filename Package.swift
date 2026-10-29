// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DnbCal",
    platforms: [.macOS(.v13)],
    targets: [
        // argument parsing and output formatting: everything that doesn't need Calendar access
        .target(name: "DnbCalCore", path: "Sources/DnbCalCore"),
        .executableTarget(
            name: "DnbCal",
            dependencies: ["DnbCalCore"],
            path: "Sources/DnbCal"
        ),
        .testTarget(
            name: "DnbCalCoreTests",
            dependencies: ["DnbCalCore"],
            path: "Tests/DnbCalCoreTests"
        ),
    ]
)
