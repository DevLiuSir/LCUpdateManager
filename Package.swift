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
                .process("Sources/LCUpdateManager/Resources/de.lproj/LCUpdateManager.strings"),
                .process("Sources/LCUpdateManager/Resources/en.lproj/LCUpdateManager.strings"),
                .process("Sources/LCUpdateManager/Resources/es.lproj/LCUpdateManager.strings"),
                .process("Sources/LCUpdateManager/Resources/fr.lproj/LCUpdateManager.strings"),
                .process("Sources/LCUpdateManager/Resources/it.lproj/LCUpdateManager.strings"),
                .process("Sources/LCUpdateManager/Resources/ja.lproj/LCUpdateManager.strings"),
                .process("Sources/LCUpdateManager/Resources/ko.lproj/LCUpdateManager.strings"),
                .process("Sources/LCUpdateManager/Resources/pt-PT.lproj/LCUpdateManager.strings"),
                .process("Sources/LCUpdateManager/Resources/ru.lproj/LCUpdateManager.strings"),
                .process("Sources/LCUpdateManager/Resources/zh-HK.lproj/LCUpdateManager.strings"),
                .process("Sources/LCUpdateManager/Resources/zh-Hans.lproj/LCUpdateManager.strings")
            ]),
        .testTarget(
            name: "LCUpdateManagerTests",
            dependencies: ["LCUpdateManager"]),
    ]
)
