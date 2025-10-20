// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "dogechat",
    defaultLocalization: "en",
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
    dependencies:[
        .package(path: "localPackages/Tor"),
        .package(path: "localPackages/BitLogger"),
        .package(url: "https://github.com/21-DOT-DEV/swift-secp256k1", exact: "0.21.1")
    ],
    targets: [
        .executableTarget(
            name: "dogechat",
            dependencies: [
                .product(name: "P256K", package: "swift-secp256k1"),
                .product(name: "BitLogger", package: "BitLogger"),
                .product(name: "Tor", package: "Tor")
            ],
            path: "dogechat",
            exclude: [
                "Info.plist",
                "Assets.xcassets",
                "dogechat.entitlements",
                "dogechat-macOS.entitlements",
                "LaunchScreen.storyboard"
            ],
            resources: [
                .process("Localizable.xcstrings")
            ]
        ),
        .testTarget(
            name: "dogechatTests",
            dependencies: ["dogechat"],
            path: "dogechatTests",
            exclude: [
                "Info.plist",
                "README.md"
            ],
            resources: [
                .process("Localization")
            ]
        )
    ]
)
