//
//  RudderLogger.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderLogger : NSObject

extern int const RudderLogLevelVerbose;
extern int const RudderLogLevelDebug;
extern int const RudderLogLevelInfo;
extern int const RudderLogLevelWarning;
extern int const RudderLogLevelError;
extern int const RudderLogLevelNone;

+ (void) initiate: (int) _logLevel;

+ (void) logVerbose: (NSString*) message;
+ (void) logDebug: (NSString*) message;
+ (void) logInfo: (NSString*) message;
+ (void) logWarn: (NSString*) message;
+ (void) logError: (NSString*) message;

@end

NS_ASSUME_NONNULL_END
