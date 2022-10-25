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
        _dataResidencyServer = US;
        _flushQueueSize = RSFlushQueueSize;
        _dbCountThreshold = RSDBCountThreshold;
        _sleepTimeout = RSSleepTimeout;
        _logLevel = RSLogLevelError;
        _configRefreshInterval = RSConfigRefreshInterval;
        _sessionInActivityTimeOut = RSSessionInActivityDefaultTimeOut;
        _trackLifecycleEvents = RSTrackLifeCycleEvents;
        _recordScreenViews = RSRecordScreenViews;
        _enableBackgroundMode = RSEnableBackgroundMode;
        _automaticSessionTracking = RSAutomaticSessionTracking;
        _controlPlaneUrl = RSControlPlaneUrl;
        _factories = [[NSMutableArray alloc] init];
        _customFactories = [[NSMutableArray alloc] init];
    }
    return self;
}

- (instancetype)init:(NSString *) dataPlaneUrl
withDataResidencyServer: (DataResidencyServer) dataResidencyServer
      flushQueueSize: (int) flushQueueSize
    dbCountThreshold: (int) dbCountThreshold
        sleepTimeOut: (int) sleepTimeout
            logLevel: (int) logLevel
sessionInActivityTimeOut: (long) sessionInActivityTimeOut
configRefreshInterval: (int) configRefreshInteval
trackLifecycleEvents: (BOOL) trackLifecycleEvents
enableBackgroundMode: (BOOL) enableBackgroundMode
automaticSessionTracking: (BOOL) automaticSessionTracking
   recordScreenViews: (BOOL) recordScreenViews
     controlPlaneUrl: (NSString *) controlPlaneUrl
{
    self = [super init];
    if (self) {
        _dataPlaneUrl = dataPlaneUrl;
        _dataResidencyServer = dataResidencyServer;
        _flushQueueSize = flushQueueSize;
        _dbCountThreshold = dbCountThreshold;
        _sleepTimeout = sleepTimeout;
        _sessionInActivityTimeOut = sessionInActivityTimeOut;
        _logLevel = logLevel;
        _configRefreshInterval = configRefreshInteval;
        _trackLifecycleEvents = trackLifecycleEvents;
        _recordScreenViews = recordScreenViews;
        _controlPlaneUrl = controlPlaneUrl;
        _enableBackgroundMode = enableBackgroundMode;
        _automaticSessionTracking = automaticSessionTracking;
        _factories = [[NSMutableArray alloc] init];
        _customFactories = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
