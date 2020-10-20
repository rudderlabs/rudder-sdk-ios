# What is Rudder?

**Short answer:**
Rudder is an open-source Segment alternative written in Go, built for the enterprise.

**Long answer:**
Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.

Released under [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)

## Installation
Rudder is available through [CocoaPods](https://cocoapods.org).
To install it, simply add the following line to your Podfile:
```xcode
pod 'Rudder', '1.0.9'
```
Remember to include the following code in all `.m` and `.h` files where you want to refer to or use Rudder SDK classes
```xcode
#import <Rudder/Rudder.h>
```

## Initialize Client
Now initialize `RSClient`
Put this code in your `AppDelegate.m` file under the method `didFinishLaunchingWithOptions`

```xcode
RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
[builder withDataPlaneUrl:<DATA_PLANE_URL>];
[RSClient getInstance:<WRITE_KEY> config:[builder build]];
```
A shared instance of `RSClient` is accesible after the initialization by `[RSClient sharedInstance]`
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

For more detailed documentation check [our documentation page](https://docs.rudderlabs.com/sdk-integration-guide/getting-started-with-ios-sdk)

## Contact Us
If you come across any issues while configuring or using RudderStack, please feel free to [contact us](https://rudderstack.com/contact/) or start a conversation on our [Discord](https://discordapp.com/invite/xNEdEGw) channel. We will be happy to help you.
