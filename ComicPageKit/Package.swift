// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ComicPageKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ComicPageKit",
            targets: ["ComicPageKit"]),
    ],
    dependencies: [
        .package(path: "../DBMultiverseSharedUI")
    ],
    targets: [
        .target(
            name: "ComicPageKit",
            dependencies: [
                "DBMultiverseSharedUI"
            ]
        ),
        .testTarget(
            name: "ComicPageKitTests",
            dependencies: ["ComicPageKit"]),
    ]
)
