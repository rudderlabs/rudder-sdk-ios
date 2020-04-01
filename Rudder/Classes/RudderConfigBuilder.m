//
//  RudderConfigBuilder.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderConfigBuilder.h"
#import "RudderLogger.h"
#import "Constants.h"

@implementation RudderConfigBuilder

- (instancetype) withDataPlaneUrl: (NSString*) dataPlaneUrl {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.dataPlaneUrl = dataPlaneUrl;
    return self;
}

- (instancetype) withFlushQueueSize: (int) flushQueueSize {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.flushQueueSize = flushQueueSize;
    return self;
}

- (instancetype) withDebug: (BOOL) debug {
    [RudderLogger initiate:RudderLogLevelVerbose];
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.logLevel = RudderLogLevelVerbose;
    return self;
}

- (instancetype) withLoglevel: (int) logLevel {
    [RudderLogger initiate:logLevel];
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.logLevel = logLevel;
    return self;
}

- (instancetype) withDBCountThreshold: (int) dbCountThreshold {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.dbCountThreshold = dbCountThreshold;
    return self;
}

- (instancetype) withSleepTimeOut: (int) sleepTimeOut {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.sleepTimeout = sleepTimeOut;
    return self;
}

- (instancetype) withFactory:(id<RudderIntegrationFactory>)factory {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    [config.factories addObject:factory];
    return self;
}

- (instancetype)withConfigRefreshInteval:(int)configRefreshInterval {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.configRefreshInterval = configRefreshInterval;
    return self;
}

- (instancetype)withTrackLifecycleEvens:(BOOL)trackLifecycleEvents {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.trackLifecycleEvents = trackLifecycleEvents;
    return self;
}

- (instancetype) withRecordScreenViews:(BOOL)recordScreenViews {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.recordScreenViews = recordScreenViews;
    return self;
}

- (instancetype)withControlPlaneUrl:(NSString *)controlPlaneUrl {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.controlPlaneUrl = controlPlaneUrl;
    return self;
}

- (RudderConfig*) build {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    return config;
}
@end
