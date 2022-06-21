<p align="center">
  <a href="https://rudderstack.com/">
    <img src="https://user-images.githubusercontent.com/59817155/121357083-1c571300-c94f-11eb-8cc7-ce6df13855c9.png">
  </a>
</p>

<p align="center"><b>The Customer Data Platform for Developers</b></p>

<p align="center">
  <a href="https://cocoapods.org/pods/Rudder">
    <img src="https://img.shields.io/static/v1?label=pod&message=v2.1.0&color=blue&style=flat">
    </a>
</p>

<p align="center">
  <b>
    <a href="https://rudderstack.com">Website</a>
    ·
    <a href="https://www.rudderstack.com/docs/stream-sources/rudderstack-sdk-integration-guides/rudderstack-ios-sdk/ios-v2/">Documentation</a>
    ·
    <a href="https://rudderstack.com/join-rudderstack-slack-community">Community Slack</a>
  </b>
</p>

---

# RudderStack iOS SDK

The RudderStack iOS SDK lets you track event data from your **iOS**, **tvOS**, **watchOS** and **macOS** applications. After integrating the SDK, you will also be able to send these events to your to your specified destinations via RudderStack.

| For more information on the RudderStack iOS SDK, refer to the [**SDK documentation**](https://www.rudderstack.com/docs/stream-sources/rudderstack-sdk-integration-guides/rudderstack-ios-sdk/ios-v2/). |
| :--|

## What's new in v2

The latest version of the iOS SDK (v2) includes the following features:

- Support tracking events in the macOS applications
- You can now track push notifications

## Installing the SDK

The iOS SDK is available through [**CocoaPods**](https://cocoapods.org), [**Carthage**](https://github.com/Carthage/Carthage), and [**Swift Package Manager (SPM)**](https://www.swift.org/package-manager/).

### CocoaPods

To install the SDK, simply add the following line to your Podfile:

```xcode
pod 'Rudder', '2.1.0'
```

### Carthage

For Carthage support, add the following line to your `Cartfile`:

```xcode
github "rudderlabs/rudder-sdk-ios" "v2.1.0"
```

> Remember to include the following code where you want to refer to or use the RudderStack SDK classes, as shown:

#### Objective C

```objective-c
@import Rudder;
```

#### Swift

```swift
import Rudder
```

### Swift Package Manager(SPM)

You can also add the RudderStack SDK using the Swift Package Mangaer in one of the following two ways:

* [Xcode](#xcode)
* [Swift](#swift)

#### Xcode

1. Go to **File** > **Add Package**, as shown:

![Adding a package](https://user-images.githubusercontent.com/59817155/140903027-286a1d64-f5d5-4041-9827-47b6cef76a46.png)

2. Enter the package repository (`git@github.com:rudderlabs/rudder-sdk-ios.git`) in the search bar.
3. In **Dependency Rule**, select **Up to Next Major Version**, and enter `2.1.0` as the value, as shown:

![Setting the dependency](https://user-images.githubusercontent.com/59817155/145574696-8c849749-13e0-40d5-aacb-3fccb5c8e67d.png)

4. Select the project to which you want to add the package.
5. Finally, click **Add Package**.

#### Swift

To leverage `package.swift`, use the following snippet in your project:

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
        .package(url: "git@github.com:rudderlabs/rudder-sdk-ios.git", from: "2.1.0")
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

To the initialize `RSClient`, place the following code in your `AppDelegate` file under the method `didFinishLaunchingWithOptions`:

#### Objective C

```objective-c
RSConfig *config = [[RSConfig alloc] initWithWriteKey:WRITE_KEY];
[config dataPlaneURL:DATA_PLANE_URL];
[config recordScreenViews:YES];
[[RSClient sharedInstance] configureWith:config];
```
#### Swift

```swift
let config: RSConfig = RSConfig(writeKey: WRITE_KEY)
            .dataPlaneURL(DATA_PLANE_URL)
            .loglevel(.debug)
            .trackLifecycleEvents(true)
            .recordScreenViews(true)
RSClient.sharedInstance().configure(with: config)
```

## Sending events

### Identify

The `identify` call lets you identify a visiting user and associate them to their actions. It also lets you record the traits about them like their name, email address, etc.

A sample `identify` call is shown in the following sections:

#### Objective C

```objective-c
[[RSClient sharedInstance] identify:@"test_user_id" traits:@{
    @"foo": @"bar",
    @"foo1": @"bar1",
    @"email": @"test@gmail.com"
}];
```
#### Swift

```swift
RSClient.sharedInstance().identify("test_user_id", traits:[
    "foo": "bar",
    "foo1": "bar1",
    "email": "test@email.com"
])
```

### Track

The `track` call lets you record the user events along with any properties associated with them.

A sample `track` call is shown in the following sections:

#### Objective C

```objective-c
[[RSClient sharedInstance] track:@"sample_track_call"];
[[RSClient sharedInstance] track:@"sample_track_call" properties:@{
    @"key_1" : @"value_1",
    @"key_2" : @"value_2"
}];
```
#### Swift

```swift
RSClient.sharedInstance().track("sample_track_call")
RSClient.sharedInstance().track("sample_track_call", properties:[
    "key_1" : "value_1",
    "key_2" : "value_2"
])
```
### Screen

The `screen` call lets you record whenever a user views their mobile screen, with any additional relevant information about the screen.

A sample `screen` call is shown in the following sections:

#### Objective C

```objective-c
[[RSClient sharedInstance] screen:@"Main" properties:@{@"prop_key" : @"prop_value"}];
```
#### Swift

```swift
RSClient.sharedInstance().screen("Main", properties:["prop_key" : "prop_value"]);
```

### Group

The `group` call lets you link an identified user with a group like a company, organization, or an account. It also lets you record any traits associated with that group, like the name of the company, number of employees, etc.

A sample `group` call is shown in the following sections:

#### Objective C

```objective-c
[[RSClient sharedInstance] group:@"sample_group_id" traits:@{
    @"foo": @"bar", 
    @"foo1": @"bar1", 
    @"email": @"test@gmail.com"
}];
```
#### Swift

```swift
RSClient.sharedInstance().group("sample_group_id" traits:[
    "foo": "bar", 
    "foo1": "bar1", 
    "email": "test@gmail.com"
])
```
### Alias

The `alias` call associates the user with a new identification.

A sample `alias` call is shown in the following sections:

#### Objective C

```objective-c
[[RSClient sharedInstance] alias:@"new_user_id"];
```
#### Swift

```swift
RSClient.sharedInstance().alias("new_user_id")
```
### Reset

The `reset` call resets the user identification and clears any persisted user traits set in the `identify` call.

A sample `reset` call is shown in the following sections:

#### Objective C

```objective-c
[[RSClient sharedInstance] reset];
```
#### Swift

```swift
RSClient.sharedInstance().reset()
```

## Supported device mode destinations

| Integration | Package |
| --- | --- |
| Adjust | https://github.com/rudderlabs/rudder-integration-adjust-swift |
| AppCenter | https://github.com/rudderlabs/rudder-integration-appcenter-swift |
| AppsFlyer | https://github.com/rudderlabs/rudder-integration-appsflyer-swift |
| Branch | https://github.com/rudderlabs/rudder-integration-branch-swift |
| Bugsnag | https://github.com/rudderlabs/rudder-integration-bugsnag-swift |
| Firebase | https://github.com/rudderlabs/rudder-integration-firebase-swift |
| Kochava | https://github.com/rudderlabs/rudder-integration-kochava-swift |
| MoEngage | https://github.com/rudderlabs/rudder-integration-moengage-swift |
| Singular | https://github.com/rudderlabs/rudder-integration-singular-swift |

## Contribute

We would love to see you contribute to this project. Get more information on how to contribute [**here**](./CONTRIBUTING.md).

## About RudderStack

[**RudderStack**](https://rudderstack.com/) is a **customer data platform for developers**. Our tooling makes it easy to deploy pipelines that collect customer data from every app, website and SaaS platform, then activate it in your warehouse and business tools.

More information on RudderStack can be found [**here**](https://github.com/rudderlabs/rudder-server).

## Contact us

For more information on using the RudderStack iOS SDK, you can [**contact us**](https://rudderstack.com/contact/) or start a conversation on our [**Slack**](https://rudderstack.com/join-rudderstack-slack-community) channel.
