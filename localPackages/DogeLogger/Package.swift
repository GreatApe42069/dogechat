// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DogeLogger",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "DogeLogger",
            targets: ["DogeLogger"]
        )
    ],
    targets: [
        .target(
            name: "DogeLogger",
            path: "Sources"
        ),
        .testTarget(
            name: "DogeLoggerTests",
            dependencies: ["DogeLogger"]
        )
    ]
)
