//
//  RSConfigBuilder.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSConfigBuilder.h"
#import "RSLogger.h"
#import "RSConstants.h"

@implementation RSConfigBuilder

- (instancetype) withEndPointUrl:(NSString *)endPointUrl{
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    NSURL *url = [[NSURL alloc] initWithString:endPointUrl];
    if ([url port]) {
        config.dataPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@:%@", [url scheme], [url host], [url port]];
    } else {
        config.dataPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@", [url scheme], [url host]];
    }
    return self;
}

- (instancetype) withDataPlaneUrl: (NSString*) dataPlaneUrl {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    
    NSURL *url = [[NSURL alloc] initWithString:dataPlaneUrl];
    if ([url port]) {
        config.dataPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@:%@", [url scheme], [url host], [url port]];
    } else {
        config.dataPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@", [url scheme], [url host]];
    }
    return self;
}

- (instancetype)withDataPlaneURL:(NSURL *) dataPlaneURL {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    if ([dataPlaneURL port]) {
        config.dataPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@:%@", [dataPlaneURL scheme], [dataPlaneURL host] ,[dataPlaneURL port]];
    } else {
        config.dataPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@", [dataPlaneURL scheme], [dataPlaneURL host]];
    }
    return self;
}

- (instancetype) withFlushQueueSize: (int) flushQueueSize {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.flushQueueSize = flushQueueSize;
    return self;
}

- (instancetype) withDebug: (BOOL) debug {
    [RSLogger initiate:RSLogLevelVerbose];
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.logLevel = RSLogLevelVerbose;
    return self;
}

- (instancetype) withLoglevel: (int) logLevel {
    [RSLogger initiate:logLevel];
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.logLevel = logLevel;
    return self;
}

- (instancetype) withDBCountThreshold: (int) dbCountThreshold {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.dbCountThreshold = dbCountThreshold;
    return self;
}

- (instancetype) withSleepTimeOut: (int) sleepTimeOut {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.sleepTimeout = sleepTimeOut;
    return self;
}

- (instancetype) withFactory:(id<RSIntegrationFactory>)factory {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    [config.factories addObject:factory];
    return self;
}

- (instancetype) withCustomFactory: (id <RSIntegrationFactory>) customFactory {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    [config.customFactories addObject:customFactory];
    return self;
}

- (instancetype)withConfigRefreshInteval:(int)configRefreshInterval {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.configRefreshInterval = configRefreshInterval;
    return self;
}

- (instancetype)withTrackLifecycleEvens:(BOOL)trackLifecycleEvents {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.trackLifecycleEvents = trackLifecycleEvents;
    return self;
}

- (instancetype) withRecordScreenViews:(BOOL)recordScreenViews {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.recordScreenViews = recordScreenViews;
    return self;
}

-(instancetype)withConfigPlaneUrl:(NSString *) configPlaneUrl {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    NSURL *url = [[NSURL alloc] initWithString:configPlaneUrl];
    if([url path]){
        config.controlPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@%@", [url scheme], [url host], [url path]];
        return self;
    }
    config.controlPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@", [url scheme], [url host]];
    return self;
}

- (instancetype)withControlPlaneUrl:(NSString *) controlPlaneUrl {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    NSURL *url = [[NSURL alloc] initWithString:controlPlaneUrl];
    if([url path]){
        config.controlPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@%@", [url scheme], [url host], [url path]];
        return self;
    }
    config.controlPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@", [url scheme], [url host]];
    return self;
}

- (instancetype)withControlPlaneURL:(NSURL *) controlPlaneURL {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    if([controlPlaneURL path]){
        config.controlPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@%@", [controlPlaneURL scheme], [controlPlaneURL host], [controlPlaneURL path]];
        return self;
    }
    config.controlPlaneUrl = [[NSString alloc] initWithFormat:@"%@://%@", [controlPlaneURL scheme], [controlPlaneURL host]];
    return self;
}

- (RSConfig*) build {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    return config;
}
@end
