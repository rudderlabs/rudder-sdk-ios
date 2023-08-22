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

- (instancetype)init {
    self = [super init];
    if (self) {
        _dataPlaneUrl = nil;
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
        _collectDeviceId = RSCollectDeviceId;
        _controlPlaneUrl = RSControlPlaneUrl;
        _factories = [[NSMutableArray alloc] init];
        _customFactories = [[NSMutableArray alloc] init];
        _gzip = RSGzipStatus;
        _dbEncryption = nil;
    }
    return self;
}

@end
