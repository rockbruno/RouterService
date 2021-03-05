// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// This package has a dummy target that depends on the executable product (xcodegen) of the XcodeGen package. This will
// enable us to use the xcodegen binary without the need to install it through homebrew by just calling `swift run xcodegen`.
let package = Package(
    name: "XcodeGenWrapper",
    platforms: [.macOS(.v10_13)],
    dependencies: [
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", from: "2.18.0")
    ],
    targets: [
        .target(
            name: "Dummy",
            dependencies: ["xcodegen"],
            path: "Resources"
        )
    ]
)
