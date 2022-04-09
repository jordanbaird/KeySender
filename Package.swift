// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "KeySender",
    platforms: [.macOS(.v10_11)],
    products: [
        .library(
            name: "KeySender",
            targets: ["KeySender"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "KeySender",
            dependencies: []),
        .testTarget(
            name: "KeySenderTests",
            dependencies: ["KeySender"]),
    ]
)
