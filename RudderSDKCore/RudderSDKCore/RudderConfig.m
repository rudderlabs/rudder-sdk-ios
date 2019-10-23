//
//  RudderConfig.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderConfig.h"

@implementation RudderConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        _endPointUrl = @"https://api.rudderlabs.com";
        _flushQueueSize = 30;
        _dbCountThreshold = 10000;
        _sleepTimeout = 10;
        _logLevel = 4;
        _factories = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)init:
(NSString *) endPointUrl flushQueueSize: (int) flushQueueSize dbCountThreshold: (int) dbCountThreshold sleepTimeOut: (int) sleepTimeout logLevel: (int) logLevel
{
    self = [super init];
    if (self) {
        _endPointUrl = endPointUrl;
        _flushQueueSize = flushQueueSize;
        _dbCountThreshold = dbCountThreshold;
        _sleepTimeout = sleepTimeout;
        _logLevel = logLevel;
        _factories = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
