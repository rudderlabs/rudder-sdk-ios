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
pod 'Rudder', '1.0.1-beta.4'
```
Remember to include the following code in all `.m` and `.h` files where you want to refer to or use Rudder SDK classes
```xcode
#import "Rudder.h"
```

## Initialize Client
Now initialize ```RudderClient```
Put this code in your ```AppDelegate.m``` file under the method ```didFinishLaunchingWithOptions```

```xcode
RudderConfigBuilder *builder = [[RudderConfigBuilder alloc] init];
[builder withDataPlaneUrl:<YOUR_DATA_PLANE_URL>];
[RudderClient getInstance:<YOUR_WRITE_KEY> config:[builder build]];
```
A shared instance of ```RudderClient``` is accesible after the initialization by ```[RudderClient sharedInstance]```
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
[[RudderClient sharedInstance] trackMessage:[builder build]];
```
OR
Send events in Segment compatible way
```xcode
[[RudderClient sharedInstance] track:@"test_event_only_name"];

[[RudderClient sharedInstance] track:@"test_event_name_prop" properties:property]; // same property dict from above is referred again
```

For more detailed documentation check [our documentation page](https://docs.rudderlabs.com/sdk-integration-guide/getting-started-with-ios-sdk)

## Contact Us
If you come across any issues while configuring or using RudderStack, please feel free to [contact us](https://rudderstack.com/contact/) or start a conversation on our [Discord](https://discordapp.com/invite/xNEdEGw) channel. We will be happy to help you.
