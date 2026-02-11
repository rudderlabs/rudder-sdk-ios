// swift-tools-version:5.3

/*
┌────────────────────────────────────────────────────────────────────┐
│                     ⚠️ DEPRECATION WARNING                         │
├────────────────────────────────────────────────────────────────────┤
│ This version of the RudderStack iOS SDK is deprecated and is       │
│ no longer actively maintained.                                     │
│ Please migrate to the newer Swift-based iOS SDK for continued      │
│                                                                    │
│ support, bug fixes, and new features.                              │
│                                                                    │
│ Swift SDK Repository:                                              │
│ https://github.com/rudderlabs/rudder-sdk-swift                     │
│                                                                    │
│ Documentation:                                                     │
│ https://www.rudderstack.com/docs/sources/event-streams/sdks/       │
│ swift-sdk/                                                         │
│                                                                    │
│ Migration Documentation:                                           │
│ https://www.rudderstack.com/docs/sources/event-streams             │
│ /sdks/swift-sdk/breaking-changes/ios-v2/migration-guide/           │
│                                                                    │
│ This SDK will be sunset in the near future. We strongly            │
│ recommend migrating as soon as possible.                           │
└────────────────────────────────────────────────────────────────────┘
*/

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
            sources: ["Classes/"],
            resources: [
                .copy("Resources/PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "RudderTests",
            dependencies: ["Rudder"]
        )
    ]
)
