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

In case you do not have CocoaPods installed, you can install the same using the following command


```xcode
sudo gem install cocoapods
```

Remember to include the following code in all .m files where you want to use 
Rudder SDK classes

```xcode
#import "RudderSDKCore.h"
```

Following are few sample usages of the SDK (code to be included in .m files)


```xcode
RudderConfigBuilder *rudderConfigBuilder = [[RudderConfigBuilder alloc] init];
[rudderConfigBuilder withEndPointUrl:@"http://dataplaneurl.com"];
RudderClient *client = [RudderClient getInstance:@"YOUR_WRITE_KEY" config: [rudderConfigBuilder build]];
RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
[builder setEventName:@"Objective-C SDK"];
RudderMessage *message = [builder build];    
[client track:message];
```

```xcode
RudderConfigBuilder *rudderConfigBuilder = [[RudderConfigBuilder alloc] init];
[rudderConfigBuilder withEndPointUrl:@"http://dataplaneurl.com"];    
RudderClient *client = [RudderClient getInstance:@"YOUR_WRITE_KEY" config: [rudderConfigBuilder build]];    
RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
[builder setEventName:@"Start Game using Objective-C SDK"];
RudderMessage *message = [builder build];
[client track:message];
```

# Coming Soon

1. Native platform SDK integration support
2. More documentation
3. More destination support

