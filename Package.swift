// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "dogechat",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "dogechat",
            targets: ["dogechat"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "dogechat",
            path: "dogechat"
        ),
    ]
)
