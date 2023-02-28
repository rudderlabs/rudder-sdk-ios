// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Rudder",
    platforms: [
        .iOS(.v9), .tvOS(.v9)
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
            publicHeadersPath: "Classes/Public/",
            cSettings: [
                .headerSearchPath("Classes/"),
                .headerSearchPath("Classes/Ecomm"),
                .headerSearchPath("Classes/Ecomm/Events")
            ]
        ),
        .testTarget(
            name: "RudderTests",
            dependencies: ["Rudder"],
            path: "Tests"
        ),
    ]
)
