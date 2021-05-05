[![Version](https://img.shields.io/cocoapods/v/Rudder.svg?style=flat)](https://cocoapods.org/pods/Rudder)

# What is RudderStack?

[RudderStack](https://rudderstack.com/) is a **customer data pipeline** tool for collecting, routing and processing data from your websites, apps, cloud tools, and data warehouse.

More information on RudderStack can be found [here](https://github.com/rudderlabs/rudder-server).

## RudderStack iOS SDK

The RudderStack iOS SDK allows you to integrate RudderStack to your iOS application in order to track event data from your app. After integrating this SDK, you will also be able to send this data to your preferred analytics destination/s such as Google Analytics, Amplitude, and more, via RudderStack.

## Installation
RudderStack is available through [CocoaPods](https://cocoapods.org) and [Carthage](https://github.com/Carthage/Carthage).

### CocoaPods
To install it, simply add the following line to your Podfile:
```xcode
pod 'Rudder', '1.0.13'
```

### Carthage
And for Carthage support add the following line to your `Cartfile`
```xcode
github "rudderlabs/rudder-sdk-ios" "v1.0.13"
```

Remember to include the following code in all `.m` and `.h` files where you want to refer to or use Rudder SDK classes
```xcode
#import <Rudder/Rudder.h>
```

## Initialize Client

To the initialize `RSClient`, put the following code in your `AppDelegate.m` file under the method `didFinishLaunchingWithOptions`:

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

For detailed documentation, check [our documentation page](https://docs.rudderstack.com/rudderstack-sdk-integration-guides/rudderstack-ios-sdk).

## Contact Us

If you come across any issues while configuring or using the RudderStack iOS SDK, please feel free to [contact us](https://rudderstack.com/contact/) or start a conversation on our [Slack](https://resources.rudderstack.com/join-rudderstack-slack) channel. We will be happy to help you.
