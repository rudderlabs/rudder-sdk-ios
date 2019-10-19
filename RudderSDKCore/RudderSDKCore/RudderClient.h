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

NS_ASSUME_NONNULL_BEGIN

@class RudderClient;

@interface RudderClient : NSObject
+ (instancetype) getInstance:(NSString*) writeKey;
+ (instancetype) getInstance:(NSString*) writeKey config:(RudderConfig*) config;
+ (instancetype) getInstance:(NSString*) writeKey builder:(RudderConfigBuilder*) builder;

- (void) trackMessage:(RudderMessage*) message;
- (void) track: (NSString*) eventName;
- (void) track: (NSString*) eventName properties: (NSDictionary<NSString*, NSObject*>*) properties;
- (void) track: (NSString *) eventName properties: (NSDictionary<NSString*, NSObject*> *) properties options:(RudderOption *) options;

- (void) screen:(RudderMessage*) message;

- (void) page:(RudderMessage*) message;

- (void) identify:(RudderMessage*) message;

@end

NS_ASSUME_NONNULL_END
