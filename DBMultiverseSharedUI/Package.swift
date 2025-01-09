// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DBMultiverseSharedUI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DBMultiverseSharedUI",
            targets: ["DBMultiverseSharedUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nikolainobadi/NnSwiftUIKit.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "DBMultiverseSharedUI",
            dependencies: [
                "NnSwiftUIKit"
            ]
        ),
        .testTarget(
            name: "DBMultiverseSharedUITests",
            dependencies: ["DBMultiverseSharedUI"]
        ),
    ]
)
