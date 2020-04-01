//
//  RudderConfig.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderConfig.h"
#import "Constants.h"
#import "RudderLogger.h"

@implementation RudderConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataPlaneUrl = RudderBaseUrl;
        _flushQueueSize = RudderFlushQueueSize;
        _dbCountThreshold = RudderDBCountThreshold;
        _sleepTimeout = RudderSleepTimeout;
        _logLevel = RudderLogLevelError;
        _configRefreshInterval = RudderConfigRefreshInterval;
        _trackLifecycleEvents = RudderTrackLifeCycleEvents;
        _recordScreenViews = RudderRecordScreenViews;
        _controlPlaneUrl = RudderControlPlaneUrl;
        _factories = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)init:(NSString *) dataPlaneUrl
      flushQueueSize: (int) flushQueueSize
    dbCountThreshold: (int) dbCountThreshold
        sleepTimeOut: (int) sleepTimeout
            logLevel: (int) logLevel
configRefreshInterval: (int) configRefreshInteval
trackLifecycleEvents: (BOOL) trackLifecycleEvents
recordScreenViews: (BOOL) recordScreenViews
      controlPlaneUrl: (NSString *) controlPlaneUrl
{
    self = [super init];
    if (self) {
        _dataPlaneUrl = dataPlaneUrl;
        _flushQueueSize = flushQueueSize;
        _dbCountThreshold = dbCountThreshold;
        _sleepTimeout = sleepTimeout;
        _logLevel = logLevel;
        _configRefreshInterval = configRefreshInteval;
        _trackLifecycleEvents = trackLifecycleEvents;
        _recordScreenViews = recordScreenViews;
        _controlPlaneUrl = controlPlaneUrl;
        _factories = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
