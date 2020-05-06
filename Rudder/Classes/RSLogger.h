//
//  RSLogger.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSLogger : NSObject

extern int const RSLogLevelVerbose;
extern int const RSLogLevelDebug;
extern int const RSLogLevelInfo;
extern int const RSLogLevelWarning;
extern int const RSLogLevelError;
extern int const RSLogLevelNone;

+ (void) initiate: (int) _logLevel;

+ (void) logVerbose: (NSString*) message;
+ (void) logDebug: (NSString*) message;
+ (void) logInfo: (NSString*) message;
+ (void) logWarn: (NSString*) message;
+ (void) logError: (NSString*) message;

@end

NS_ASSUME_NONNULL_END
