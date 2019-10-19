# What is Rudder?

[![Version](https://img.shields.io/cocoapods/v/RudderSDKCore.svg?style=flat)](https://cocoapods.org/pods/RudderSDKCore)
[![Platform](https://img.shields.io/cocoapods/p/RudderSDKCore.svg?style=flat)](https://cocoapods.org/pods/RudderSDKCore)

**Short answer:** 
Rudder is an open-source Segment alternative written in Go, built for the enterprise. .

**Long answer:** 
Rudder is a platform for collecting, storing and routing customer event data to dozens of tools. Rudder is open-source, can run in your cloud environment (AWS, GCP, Azure or even your data-centre) and provides a powerful transformation framework to process your event data on the fly.

Released under [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0)

## Installation
RudderSDKCore is available through [CocoaPods](https://cocoapods.org). 
To install it, simply add the following line to your Podfile:
```xcode
pod 'RudderSDKCore', :git => 'https://github.com/rudderlabs/rudder-sdk-ios.git', :branch => 'objective-c-src-code'
```
Remember to include the following code in all .m files where you want to use Rudder SDK classes
```xcode
#import "RudderSDKCore.h"
```

## Initialize Client
Declare RudderClient as a ```property``` in the  ```.h``` file containing your class definition
```xcode
@property (nonatomic) RudderClient *rudderClient;
```
Now initialize ```RudderClient```
Put this code in all your ```.m``` files where you want to use Ruder SDK

```xcode
RudderConfigBuilder *builder = [[RudderConfigBuilder alloc] init];
[builder withEndPointUrl:YOUR_DATA_PLANE_URL];
self.rudderClient = [RudderClient getInstance:YOUR_WRITE_KEY config:[builder build]];
```

## Sending Events
Track events by creating a ```RudderMessage``` using ```RudderMessageBuilder```
```xcode
// create properties for the event you want to track
NSMutableDictionary *property = [[NSMutableDictionary alloc] init];
[property setValue:@"test_value_1" forKey:@"test_key_1"];
[property setValue:@"test_value_2" forKey:@"test_key_2"];

// create builder
RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
[builder setEventName:@"test_event_name"];
[builder setPropertyDict:property];
[builder setUserId:userId];

// track event
[self.rudderClient trackMessage:[builder build]];
```
OR
Send events in Segment compatible way
```xcode
[self.rudderClient track:@"test_event_only_name"];

[self.rudderClient track:@"test_event_name_prop" properties:property]; // same property dict from above is referred again
```

# Coming Soon

1. Native platform SDK integration support
2. More documentation
3. More destination support

