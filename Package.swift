// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "LCUpdateManager",
    defaultLocalization: "en", // 指定默认语言为英文
    platforms: [
        .macOS(.v10_15) // 指定支持的 macOS 版本
    ],
    products: [
        .library(
            name: "LCUpdateManager",
            targets: ["LCUpdateManager"]),
    ],
    targets: [
        .target(
            name: "LCUpdateManager",
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "LCUpdateManagerTests",
            dependencies: ["LCUpdateManager"]),
    ]
)
