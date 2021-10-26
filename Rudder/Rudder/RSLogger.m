//
//  RSLogger.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSLogger.h"

static NSString *TAG = @"RSStack";
// Defaulting logLevel to 3 i.e RSLogLevelInfo
static int logLevel = 3;

@implementation RSLogger

int const RSLogLevelVerbose = 5;
int const RSLogLevelDebug = 4;
int const RSLogLevelInfo = 3;
int const RSLogLevelWarning = 2;
int const RSLogLevelError = 1;
int const RSLogLevelNone = 0;

- (instancetype)init
{
    self = [super init];
    if (self) {
        logLevel = RSLogLevelError;
    }
    return self;
}

+ (void)initiate:(int)_logLevel {
    if (_logLevel > RSLogLevelVerbose) {
        logLevel = RSLogLevelVerbose;
    } else if (_logLevel < RSLogLevelNone) {
        logLevel = RSLogLevelNone;
    } else {
        logLevel = _logLevel;
    }
}

+ (void)logVerbose:(NSString *)message {
    if (logLevel >= RSLogLevelVerbose) {
        NSLog(@"%@:Verbose:%@", TAG, message);
    }
}

+ (void)logDebug:(NSString *)message {
    if (logLevel >= RSLogLevelDebug) {
        NSLog(@"%@:Debug:%@", TAG, message);
    }
}

+ (void)logInfo:(NSString *)message {
    if (logLevel >= RSLogLevelInfo) {
        NSLog(@"%@:Info:%@", TAG, message);
    }
}

+ (void)logWarn:(NSString *)message {
    if (logLevel >= RSLogLevelWarning) {
        NSLog(@"%@:Warn:%@", TAG, message);
    }
}

+ (void)logError:(NSString *)message {
    if (logLevel >= RSLogLevelError) {
        NSLog(@"%@:Error:%@", TAG, message);
    }
}


@end
