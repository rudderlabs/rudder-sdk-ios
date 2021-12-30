//
//  RSConfig.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSConfig.h"
#import "RSConstants.h"
#import "RSLogger.h"

@implementation RSConfig
- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataPlaneUrl = RSDataPlaneUrl;
        _flushQueueSize = RSFlushQueueSize;
        _dbCountThreshold = RSDBCountThreshold;
        _sleepTimeout = RSSleepTimeout;
        _logLevel = RSLogLevelError;
        _configRefreshInterval = RSConfigRefreshInterval;
        _trackLifecycleEvents = RSTrackLifeCycleEvents;
        _recordScreenViews = RSRecordScreenViews;
        _enableBackgroundMode = RSEnableBackgroundMode;
        _controlPlaneUrl = RSControlPlaneUrl;
        _factories = [[NSMutableArray alloc] init];
        _customFactories = [[NSMutableArray alloc] init];
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
enableBackgroundMode: (BOOL) enableBackgroundMode
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
        _enableBackgroundMode = enableBackgroundMode;
        _factories = [[NSMutableArray alloc] init];
        _customFactories = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
