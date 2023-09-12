//
//  RSClient.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSConfigBuilder.h"
#import "RSOption.h"
#import "RSTraits.h"
#import "RSContext.h"

NS_ASSUME_NONNULL_BEGIN

@class RSClient;

@protocol RSIntegrationFactory;
@protocol RSIntegration;
@class RSConfig;
@class RSMessage;
@class RSContext;
@class RSMessageBuilder;

@interface RSClient : NSObject {
    RSOption *_options;
}

- (instancetype)init NS_UNAVAILABLE NS_SWIFT_UNAVAILABLE("Use `RSClient.getInstance(writeKey:)` to initialise.");

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

- (void)reset __attribute((deprecated("Discontinuing support. Implement reset: instead")));
- (void) reset:(BOOL) clearAnonymousId;
- (void)flush;

- (void) optOut: (BOOL) optOut;

- (void) shutdown;

+ (instancetype _Nullable) sharedInstance;

- (void)trackLifecycleEvents:(NSDictionary *)launchOptions;

+ (void) putAnonymousId: (NSString *_Nonnull) anonymousId;
+ (void) putDeviceToken: (NSString *_Nonnull) deviceToken;
+ (void) putAuthToken: (NSString *_Nonnull) authToken;

+ (void) setAnonymousId: (NSString *__nullable) anonymousId __attribute((deprecated("Discontinuing support. Use putAnonymousId method instead.")));;

- (void)startSession;
- (void)startSession:(long)sessionId;
- (void)endSession;

- (NSString* _Nullable)getAnonymousId __attribute((deprecated("This method will be deprecated soon. Use instance property(anonymousId) instead.")));
- (RSConfig* _Nullable)configuration __attribute((deprecated("This method will be deprecated soon. Use instance property(config) instead.")));
+ (RSOption*) getDefaultOptions __attribute((deprecated("This method will be deprecated soon. Use instance property(defaultOptions) instead.")));
- (RSContext *) getContext __attribute((deprecated("This method will be deprecated soon. Use instance property(context) instead.")));

@property (strong, nonatomic, readonly) NSNumber* _Nullable sessionId;
@property (strong, nonatomic, readonly) NSString* _Nullable anonymousId;
@property (strong, nonatomic, readonly) RSConfig* _Nullable config;
@property (strong, nonatomic, readonly) RSOption* defaultOptions;
@property (strong, nonatomic, readonly) RSContext* context;

@end

NS_ASSUME_NONNULL_END
