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

- (instancetype) withEndPointUrl: (NSString*) endPointUrl {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.endPointUrl = endPointUrl;
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
    return self;
}

- (instancetype) withLoglevel: (int) logLevel {
    [RudderLogger initiate:logLevel];
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

- (instancetype)withConfigPlaneUrl:(NSString *)configPlaneUrl {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.configPlaneUrl = configPlaneUrl;
    return self;
}

- (RudderConfig*) build {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    return config;
}
@end
