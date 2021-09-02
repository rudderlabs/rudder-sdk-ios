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
+ (instancetype) getInstance:(NSString *)writeKey config: (RSConfig*) config options: (RSOption*) options;

- (void) trackMessage:(RSMessage*) message __attribute((deprecated("Discontinuing support. Use track method instead.")));
- (void) trackWithBuilder:(RSMessageBuilder*) builder __attribute((deprecated("Discontinuing support. Use track method instead.")));
- (void) track: (NSString*) eventName;
- (void) track: (NSString*) eventName properties: (NSDictionary<NSString*, id>*) properties;
- (void) track: (NSString *) eventName properties: (NSDictionary<NSString*, id>*) properties options:(RSOption *_Nullable) options;

- (void) screenWithMessage:(RSMessage*) message __attribute((deprecated("Discontinuing support. Use screen method instead.")));
- (void) screenWithBuilder:(RSMessageBuilder*) builder __attribute((deprecated("Discontinuing support. Use screen method instead.")));
- (void) screen: (NSString*) screenName;
- (void) screen: (NSString*) screenName properties: (NSDictionary<NSString*, id>*) properties;
- (void) screen: (NSString *) screenName properties: (NSDictionary<NSString*, id>*) properties options:(RSOption *_Nullable) options;

- (void) group:(NSString *)groupId traits:(NSDictionary<NSString*, id>*)traits options:(RSOption *_Nullable) options;
- (void) group:(NSString *)groupId traits:(NSDictionary<NSString*, id>*)traits;
- (void) group:(NSString *)groupId;

- (void) alias:(NSString *)newId options:(RSOption * _Nullable) options;
- (void) alias:(NSString *)newId;

- (void) pageWithMessage: (RSMessage*) message __attribute((deprecated("Discontinuing support.")));

- (void) identifyWithMessage:(RSMessage*) message __attribute((deprecated("Discontinuing support. Use identify method instead.")));
- (void) identifyWithBuilder:(RSMessageBuilder*) builder __attribute((deprecated("Discontinuing support. Use identify method instead.")));
- (void) identify:(NSString *_Nullable)userId traits:(NSDictionary<NSString*, id>*)traits options:(RSOption *_Nullable) options;
- (void) identify:(NSString *_Nullable)userId traits:(NSDictionary<NSString*, id>*)traits;
- (void) identify:(NSString *_Nullable)userId;

- (void)reset;
- (void)flush;

- (void) optOut: (BOOL) optOut;

- (NSString* _Nullable)getAnonymousId;

- (RSConfig* _Nullable)configuration;

+ (instancetype _Nullable) sharedInstance;

+ (RSOption*) getDefaultOptions;

- (void)trackLifecycleEvents:(NSDictionary *)launchOptions;

- (RSContext *) getContext;

+ (void) setAnonymousId: (NSString *__nullable) anonymousId;

@end

NS_ASSUME_NONNULL_END
