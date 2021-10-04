[![Version](https://img.shields.io/cocoapods/v/Rudder.svg?style=flat)](https://cocoapods.org/pods/Rudder)

# RudderStack iOS SDK

RudderStack's iOS SDK lets you track event data from your iOS applications. After integrating the SDK, you will be able to send the event data to your preferred destination/s such as Google Analytics, Amplitude, and more.

For detailed documentation on the iOS SDK, click [**here**](https://docs.rudderstack.com/rudderstack-sdk-integration-guides/rudderstack-ios-sdk).

## Installing the iOS SDK

The iOS SDK is available through [**CocoaPods**](https://cocoapods.org) and [**Carthage**](https://github.com/Carthage/Carthage).

### CocoaPods

To install the SDK, simply add the following line to your Podfile:

```xcode
pod 'Rudder', '1.0.22'
```

### Carthage

For Carthage support, add the following line to your `Cartfile`:

```xcode
github "rudderlabs/rudder-sdk-ios" "v1.0.22"
```

> Remember to include the following code in all `.m` and `.h` files where you want to refer to or use the RudderStack SDK classes, as shown:

```xcode
#import <Rudder/Rudder.h>
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

For detailed documentation, click [**here**](https://docs.rudderstack.com/rudderstack-sdk-integration-guides/rudderstack-ios-sdk).

## Contact us

For more information on using the RudderStack iOS SDK, you can [**contact us**](https://rudderstack.com/contact/) or start a conversation on our [**Slack**](https://rudderstack.com/join-rudderstack-slack-community) channel.
