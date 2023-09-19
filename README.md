<p align="center">
  <a href="https://rudderstack.com/">
    <img src="https://user-images.githubusercontent.com/59817155/121357083-1c571300-c94f-11eb-8cc7-ce6df13855c9.png">
  </a>
</p>

<p align="center"><b>The Customer Data Platform for Developers</b></p>

<p align="center">
  <a href="https://cocoapods.org/pods/Rudder">
    <img src="https://img.shields.io/static/v1?label=pod&message=v1.20.0&color=blue&style=flat">
    </a>
</p>

<p align="center">
  <b>
    <a href="https://rudderstack.com">Website</a>
    ·
    <a href="https://rudderstack.com/docs/stream-sources/rudderstack-sdk-integration-guides/rudderstack-ios-sdk/">Documentation</a>
    ·
    <a href="https://rudderstack.com/join-rudderstack-slack-community">Community Slack</a>
  </b>
</p>

---

# RudderStack iOS SDK

RudderStack's iOS SDK lets you track event data from your **iOS** and **tvOS** applications. After integrating the SDK, you will also be able to send these events to your preferred destinations such as Google Analytics, Amplitude, and more.

For detailed documentation on the iOS SDK, click [**here**](https://rudderstack.com/docs/stream-sources/rudderstack-sdk-integration-guides/rudderstack-ios-sdk).

## Installing the iOS SDK

The iOS SDK is available through [**CocoaPods**](https://cocoapods.org), [**Carthage**](https://github.com/Carthage/Carthage), and [**Swift Package Manager (SPM)**](https://www.swift.org/package-manager/).

### CocoaPods

To install the SDK, simply add the following line to your Podfile:

```xcode
pod 'Rudder', '1.20.0'
```

### Carthage

For Carthage support, add the following line to your `Cartfile`:

```xcode
github "rudderlabs/rudder-sdk-ios" "v1.20.0"
```

> Remember to include the following code in all `.m` and `.h` files where you want to refer to or use the RudderStack SDK classes, as shown:

```xcode
#import <Rudder/Rudder.h>
```

### Swift Package Manager (SPM)

You can also add the RudderStack iOS SDK via Swift Package Mangaer, via one of the following two ways:

* [Xcode](#xcode)
* [Swift](#swift)

#### Xcode

* Go to **File** - **Add Package**, as shown:

![Adding a package](https://user-images.githubusercontent.com/59817155/140903027-286a1d64-f5d5-4041-9827-47b6cef76a46.png)

* Enter the package repository (`git@github.com:rudderlabs/rudder-sdk-ios.git`) in the search bar.

* In **Dependency Rule**, select **Up to Next Major Version** and enter `1.20.0` as the value, as shown:

![Setting dependency](https://user-images.githubusercontent.com/59817155/145574696-8c849749-13e0-40d5-aacb-3fccb5c8e67d.png)

* Select the project to which you want to add the package.

* Finally, click on **Add Package**.

#### Swift

To leverage package.swift, use the following snippet in your project:

```swift
// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RudderStack",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RudderStack",
            targets: ["RudderStack"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "git@github.com:rudderlabs/rudder-sdk-ios.git", from: "1.20.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RudderStack",
            dependencies: [
                .product(name: "Rudder", package: "rudder-sdk-ios")
            ]),
        .testTarget(
            name: "RudderStackTests",
            dependencies: ["RudderStack"]),
    ]
)
```

## Initializing the RudderStack client

To the initialize `RSClient`, place the following code in your `AppDelegate.m` file under the method `didFinishLaunchingWithOptions`:

```xcode
RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
[builder withDataPlaneUrl:<DATA_PLANE_URL>];
[RSClient getInstance:<WRITE_KEY> config:[builder build]];
```
A shared instance of `RSClient` is accesible after the initialization by `[RSClient sharedInstance]`.

## Sending Events

### Track

```xcode
[[RSClient sharedInstance] track:@"simple_track_event"];
[[RSClient sharedInstance] track:@"simple_track_with_props" properties:@{
    @"key_1" : @"value_1",
    @"key_2" : @"value_2"
}];
```

### Screen

```xcode
[[RSClient sharedInstance] screen:@"Main" properties:@{@"prop_key" : @"prop_value"}];
```

### Identify

```xcode
[[RSClient sharedInstance] identify:@"test_user_id"
                             traits:@{@"foo": @"bar",
                                      @"foo1": @"bar1",
                                      @"email": @"test@gmail.com"}
];
```

### Group

```xcode
[[RSClient sharedInstance] group:@"sample_group_id"
                          traits:@{@"foo": @"bar",
                                   @"foo1": @"bar1",
                                   @"email": @"test@gmail.com"}
];
```

### Alias

```xcode
[[RSClient sharedInstance] alias:@"new_user_id"];
```

### Reset

```xcode
[[RSClient sharedInstance] reset];
```

For detailed documentation on the iOS SDK, click [**here**](https://rudderstack.com/docs/stream-sources/rudderstack-sdk-integration-guides/rudderstack-ios-sdk).

## Contribute

We would love to see you contribute to this project. Get more information on how to contribute [**here**](./CONTRIBUTING.md).

## About RudderStack

[**RudderStack**](https://rudderstack.com/) is a **customer data platform for developers**. Our tooling makes it easy to deploy pipelines that collect customer data from every app, website and SaaS platform, then activate it in your warehouse and business tools.

More information on RudderStack can be found [**here**](https://github.com/rudderlabs/rudder-server).

## Contact us

For more information on using the RudderStack iOS SDK, you can [**contact us**](https://rudderstack.com/contact/) or start a conversation on our [**Slack**](https://rudderstack.com/join-rudderstack-slack-community) channel.
