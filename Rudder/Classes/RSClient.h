//
//  RSClient.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSConfig.h"
#import "RSConfigBuilder.h"
#import "RSMessage.h"
#import "RSOption.h"
#import "RSMessageBuilder.h"
#import "RSTraits.h"
#import "RSContext.h"

NS_ASSUME_NONNULL_BEGIN

@class RSClient;

@protocol RSIntegrationFactory;
@protocol RSIntegration;
@class RSConfig;

@interface RSClient : NSObject
+ (instancetype) getInstance;
+ (instancetype) getInstance:(NSString*) writeKey;
+ (instancetype) getInstance:(NSString*) writeKey config:(RSConfig*) config;

- (void) trackMessage:(RSMessage*) message __attribute((deprecated("Discontinuing support. Use track method instead.")));
- (void) trackWithBuilder:(RSMessageBuilder*) builder __attribute((deprecated("Discontinuing support. Use track method instead.")));
- (void) track: (NSString*) eventName;
- (void) track: (NSString*) eventName properties: (NSDictionary<NSString*, NSObject*>*) properties;
- (void) track: (NSString *) eventName properties: (NSDictionary<NSString*, NSObject*> *) properties options:(RSOption *_Nullable) options;

- (void) screenWithMessage:(RSMessage*) message __attribute((deprecated("Discontinuing support. Use screen method instead.")));
- (void) screenWithBuilder:(RSMessageBuilder*) builder __attribute((deprecated("Discontinuing support. Use screen method instead.")));
- (void) screen: (NSString*) screenName;
- (void) screen: (NSString*) screenName properties: (NSDictionary<NSString*, NSObject*>*) properties;
- (void) screen: (NSString *) screenName properties: (NSDictionary<NSString*, NSObject*> *) properties options:(RSOption *_Nullable) options;

- (void) group:(NSString *)groupId traits:(NSDictionary<NSString*, NSObject*>*)traits options:(RSOption *_Nullable) options;
- (void) group:(NSString *)groupId traits:(NSDictionary<NSString*, NSObject*>*)traits;
- (void) group:(NSString *)groupId;

- (void) alias:(NSString *)newId options:(RSOption * _Nullable) options;
- (void) alias:(NSString *)newId;

- (void) pageWithMessage: (RSMessage*) message __attribute((deprecated("Discontinuing support.")));

- (void) identifyWithMessage:(RSMessage*) message __attribute((deprecated("Discontinuing support. Use identify method instead.")));
- (void) identifyWithBuilder:(RSMessageBuilder*) builder __attribute((deprecated("Discontinuing support. Use identify method instead.")));
- (void) identify:(NSString *_Nullable)userId traits:(NSDictionary*)traits options:(RSOption *_Nullable) options;
- (void) identify:(NSString *_Nullable)userId traits:(NSDictionary*)traits;
- (void) identify:(NSString *_Nullable)userId;

- (void)reset;

- (NSString* _Nullable)getAnonymousId;

- (RSConfig* _Nullable)configuration;

+ (instancetype _Nullable) sharedInstance;

- (RSContext *) getContext;

@end

NS_ASSUME_NONNULL_END
