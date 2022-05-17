// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Rudder",
    platforms: [
        .iOS("12.0"), .tvOS("11.0"), .macOS("10.13"), .watchOS("7.0")
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
            path: "Sources",
            sources: ["Classes/"]
        ),
        .testTarget(
            name: "RudderTests",
            dependencies: ["Rudder"]
        )
    ]
)
