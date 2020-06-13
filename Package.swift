// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RouterService",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "RouterServiceInterface", type: .dynamic, targets: ["RouterServiceInterface"]),
        .library(name: "RouterService", type: .dynamic, targets: ["RouterService"])
    ],
    targets: [
        .target(
            name: "RouterServiceInterface"),
        .target(
            name: "RouterService",
            dependencies: ["RouterServiceInterface"]),
        .testTarget(
            name: "RouterServiceTests",
            dependencies: ["RouterService"]),
    ]
)
