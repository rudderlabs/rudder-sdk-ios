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
pod 'RudderSDKCore'
```

In case you do not have CocoaPods installed, you can install the same using the following command


```xcode
sudo gem install cocoapods
```


Following are some URLs providing instructions regarding usage of Swift Pod Frameworks in Objective-C

https://medium.com/@anum.amin/swift-pod-library-in-objective-c-project-c6d1c5af997d

https://stackoverflow.com/questions/27995691/how-to-import-and-use-swift-pod-framework-in-objective-c-project

Remember to include the following code in all .m files where you want to use Swift classes from the SDK

```xcode

@import RudderSDKCore;

```

Following are few sample usages of the SDK (code to be included in .m files)


```xcode
   RudderClient *client 
	= [RudderClient getInstanceWithWriteKey:@"1SN4NTGwxMoR2PLhl9TlLpErpge"];

    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder withEventNameWithEventName:@"Objective-C Test"];
    RudderMessage *message = [builder build];
    
    [client trackWithMessage:message];

```
```xcode
    RudderClient *client 
	= [RudderClient getInstanceWithWriteKey:@"1SN4NTGwxMoR2PLhl9TlLpErpge"];
    
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder withEventNameWithEventName:@"Start Game"];
    RudderMessage *message = [builder build];
    
    [client trackWithMessage:message];
```


# Coming Soon

1. Native platform SDK integration support
2. More documentation
3. More destination support
