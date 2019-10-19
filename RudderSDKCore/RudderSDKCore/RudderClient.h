//
//  RudderClient.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderConfig.h"
#import "RudderConfigBuilder.h"
#import "RudderMessage.h"
#import "RudderOption.h"
#import "RudderMessageBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@class RudderClient;

@interface RudderClient : NSObject
+ (instancetype) getInstance:(NSString*) writeKey;
+ (instancetype) getInstance:(NSString*) writeKey config:(RudderConfig*) config;
+ (instancetype) getInstance:(NSString*) writeKey builder:(RudderConfigBuilder*) builder;

- (void) trackMessage:(RudderMessage*) message;
- (void) trackWithBuilder:(RudderMessageBuilder*) builder;
- (void) track: (NSString*) eventName;
- (void) track: (NSString*) eventName properties: (NSDictionary<NSString*, NSObject*>*) properties;
- (void) track: (NSString *) eventName properties: (NSDictionary<NSString*, NSObject*> *) properties options:(RudderOption *) options;

- (void) screenWithMessage:(RudderMessage*) message;
- (void) screenWithBuilder:(RudderMessageBuilder*) builder;
- (void) screen: (NSString*) screenName;
- (void) screen: (NSString*) eventName properties: (NSDictionary<NSString*, NSObject*>*) properties;
- (void) screen: (NSString *) eventName properties: (NSDictionary<NSString*, NSObject*> *) properties options:(RudderOption *) options;

- (void)group:(NSString *)groupId traits:(NSDictionary<NSString*, NSObject*>*)traits options:(NSDictionary<NSString*, NSObject*>*)options;
- (void)group:(NSString *)groupId traits:(NSDictionary<NSString*, NSObject*>*)traits;
- (void)group:(NSString *)groupId;

- (void)alias:(NSString *)newId options:(NSDictionary<NSString*, NSObject*>*)options;
- (void)alias:(NSString *)newId;

- (void) identifyWithMessage:(RudderMessage*) message;
- (void) identifyWithBuilder:(RudderMessageBuilder*) builder;
- (void)identify:(NSString *_Nullable)userId traits:(NSDictionary<NSString*, NSObject*>*)traits options:(NSDictionary<NSString*, NSObject*>*)options;
- (void)identify:(NSString *_Nullable)userId traits:(NSDictionary<NSString*, NSObject*>*)traits;
- (void)identify:(NSString *_Nullable)userId;

- (void)reset;

- (NSString *)getAnonymousId;

- (RudderConfig *)configuration;

- (void) page:(RudderMessage*) message;

+ (instancetype _Nullable) sharedAnalytics;

@end

NS_ASSUME_NONNULL_END
