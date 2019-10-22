//
//  RudderConfigBuilder.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderConfigBuilder.h"
#import "RudderLogger.h"

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
    [RudderLogger initiate:5];
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

- (RudderConfig*) build {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    return config;
}
@end
