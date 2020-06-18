// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Rudder",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "Rudder",
            type: .dynamic,
            targets: ["Rudder"]
        )
    ],
    targets: [
        .target(
            name: "Rudder",
            path: "Rudder",
            sources: ["Classes"],
            publicHeadersPath: "Classes/**",
            cSettings: [
                .headerSearchPath("Classes/**")
            ]
        )
    ]
)
