// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "Rudder",
    platforms: [
        .iOS("12.0"),
        .tvOS("12.0"),
        .macOS("10.13"),
        .watchOS("7.0")
    ],
    products: [
        .library(
            name: "Rudder",
            targets: ["Rudder"]
        )
    ],
    targets: [
        .target(
            name: "Rudder",
            dependencies: [
                .target(name: "RudderInternal")
            ],
            path: "RudderCore/Sources"
        ),
        .testTarget(
            name: "RudderCoreTests",
            dependencies: [
                .target(name: "Rudder"),
                .target(name: "RudderInternal")
            ],
            path: "RudderCore/Tests"
        ),
        .target(
            name: "RudderInternal",
            path: "RudderInternal/Sources"
        )
    ]
)
