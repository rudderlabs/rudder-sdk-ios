//
//  RudderLogger.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderLogger.h"

static NSString *TAG = @"RudderSDKCore";
static int logLevel;

@implementation RudderLogger

int const RudderLogLevelVerbose = 5;
int const RudderLogLevelDebug = 4;
int const RudderLogLevelInfo = 3;
int const RudderLogLevelWarning = 2;
int const RudderLogLevelError = 1;
int const RudderLogLevelNone = 0;

- (instancetype)init
{
    self = [super init];
    if (self) {
        logLevel = RudderLogLevelError;
    }
    return self;
}

+ (void)initiate:(int)_logLevel {
    if (_logLevel > RudderLogLevelVerbose) {
        logLevel = RudderLogLevelVerbose;
    } else if (_logLevel < RudderLogLevelNone) {
        logLevel = RudderLogLevelNone;
    } else {
        logLevel = _logLevel;
    }
}

+ (void)logVerbose:(NSString *)message {
    if (logLevel >= RudderLogLevelVerbose) {
        NSLog(@"%@:Verbose:%@", TAG, message);
    }
}

+ (void)logDebug:(NSString *)message {
    if (logLevel >= RudderLogLevelDebug) {
        NSLog(@"%@:Debug:%@", TAG, message);
    }
}

+ (void)logInfo:(NSString *)message {
    if (logLevel >= RudderLogLevelInfo) {
        NSLog(@"%@:Info:%@", TAG, message);
    }
}

+ (void)logWarn:(NSString *)message {
    if (logLevel >= RudderLogLevelWarning) {
        NSLog(@"%@:Warn:%@", TAG, message);
    }
}

+ (void)logError:(NSString *)message {
    if (logLevel >= RudderLogLevelError) {
        NSLog(@"%@:Error:%@", TAG, message);
    }
}


@end
