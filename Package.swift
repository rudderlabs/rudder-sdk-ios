// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Rudder",
    platforms: [
        .iOS(.v9), .tvOS(.v10)
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
            sources: ["Classes/"],
            publicHeadersPath: "Classes/Headers/Public/",
            cSettings: [
                .headerSearchPath("Classes/Headers/")
            ]
        ),
        .testTarget(
            name: "RudderTests",
            dependencies: ["Rudder"],
            path: "Tests"
        ),
    ]
)
