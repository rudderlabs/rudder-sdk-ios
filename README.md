<p align="center">
  <a href="https://rudderstack.com/">
    <img src="https://user-images.githubusercontent.com/59817155/121357083-1c571300-c94f-11eb-8cc7-ce6df13855c9.png">
  </a>
</p>

<p align="center"><b>The Customer Data Platform for Developers</b></p>

<p align="center">
  <a href="https://cocoapods.org/pods/Rudder">
    <img src="https://img.shields.io/cocoapods/v/Rudder.svg?style=flat">
    </a>
</p>

<p align="center">
  <b>
    <a href="https://rudderstack.com">Website</a>
    ·
    <a href="https://rudderstack.com/docs/stream-sources/rudderstack-sdk-integration-guides/rudderstack-ios-sdk/">Documentation</a>
    ·
    <a href="https://rudderstack.com/join-rudderstack-slack-community">Slack</a>
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
pod 'Rudder', '1.1.4'
```

### Carthage

For Carthage support, add the following line to your `Cartfile`:

```xcode
github "rudderlabs/rudder-sdk-ios" "v1.1.4"
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

* Go to **File** - **Swift Packages** - **Add Package Dependency...**, as shown:

* Enter the package repository (git@github.com:rudderlabs/rudder-sdk-ios.git) in the search bar, as shown:

* In **Choose Package Options**, go to **Rules**. Select the **Version** as **Up to Next Major** and enter as the value, as shown:

#### Swift

To leverage package.swift, use the following snippet in your project:

```swift
import PackageDescription

let package = Package(
    name: "RudderApp",
    dependencies: [
        // Add a package containing Analytics as the name along with the git url
        .package(
            name: " ",
            url: ""
        )
    ],
    targets: [
        name: "MyiOSApplication",
        dependencies: [" "] // Add the SDK as a dependency
    ]
)
```

> **We highly recommend using Xcode to add your package.** 

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
