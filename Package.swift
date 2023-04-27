// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "KeySender",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .library(
            name: "KeySender",
            targets: ["KeySender"]
        )
    ],
    targets: [
        .target(
            name: "KeySender"
        )
    ]
)
