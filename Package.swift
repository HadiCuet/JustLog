// swift-tools-version: 5.7

// This file was automatically generated by PackageGenerator and untracked
// PLEASE DO NOT EDIT MANUALLY

import PackageDescription

let package = Package(
    name: "JustLog",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v7),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "JustLog",
            targets: ["JustLog"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/SwiftyBeaver/SwiftyBeaver",
            exact: "2.1.1"
        ),
    ],
    targets: [
        .target(
            name: "JustLog",
            dependencies: [
                .product(name: "SwiftyBeaver", package: "SwiftyBeaver"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "JustLogTests",
            dependencies: [
                .byName(name: "JustLog"),
            ],
            path: "Tests"
        ),
    ]
)
