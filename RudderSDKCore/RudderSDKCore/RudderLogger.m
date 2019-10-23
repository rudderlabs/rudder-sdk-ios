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

- (instancetype)init
{
    self = [super init];
    if (self) {
        logLevel = 3;
    }
    return self;
}

+ (void)initiate:(int)_logLevel {
    if (_logLevel > 5) {
        logLevel = 5;
    } else if (_logLevel < 0) {
        logLevel = 0;
    } else {
        logLevel = _logLevel;
    }
}

+ (void)logVerbose:(NSString *)message {
    if (logLevel >= 5) {
        NSLog(@"%@:Verbose:%@", TAG, message);
    }
}

+ (void)logDebug:(NSString *)message {
    if (logLevel >= 4) {
        NSLog(@"%@:Debug:%@", TAG, message);
    }
}

+ (void)logInfo:(NSString *)message {
    if (logLevel >= 3) {
        NSLog(@"%@:Info:%@", TAG, message);
    }
}

+ (void)logWarn:(NSString *)message {
    if (logLevel >= 2) {
        NSLog(@"%@:Warn:%@", TAG, message);
    }
}

+ (void)logError:(NSString *)message {
    if (logLevel >= 1) {
        NSLog(@"%@:Error:%@", TAG, message);
    }
}


@end
