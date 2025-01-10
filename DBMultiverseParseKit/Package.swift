// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DBMultiverseParseKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DBMultiverseParseKit",
            targets: ["DBMultiverseParseKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.0"),
    ],
    targets: [
        .target(
            name: "DBMultiverseParseKit",
            dependencies: [
                "SwiftSoup"
            ]
        ),
    ]
)
