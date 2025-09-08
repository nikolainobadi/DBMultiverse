// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DBMultiverseComicKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "DBMultiverseComicKit",
            targets: ["DBMultiverseComicKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/nikolainobadi/NnTestKit", from: "1.0.0"),
        .package(url: "https://github.com/nikolainobadi/NnSwiftUIKit.git", branch: "swift-6")
    ],
    targets: [
        .target(
            name: "DBMultiverseComicKit",
            dependencies: [
                "NnSwiftUIKit"
            ]
        ),
        .testTarget(
            name: "DBMultiverseComicKitTests",
            dependencies: [
                "DBMultiverseComicKit",
                .product(name: "NnSwiftTestingHelpers", package: "NnTestKit")
            ]
        ),
    ]
)
