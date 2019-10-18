//
//  RudderConfigBuilder.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderConfigBuilder.h"

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
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.logLevel = 5;
    return self;
}

- (instancetype) withLoglevel: (int) logLevel {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.flushQueueSize = 5;
    return self;
}

- (instancetype) withDBThreshold: (int) dbThreshold {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.dbCountThreshold = dbThreshold;
    return self;
}

- (instancetype) withSleepTimeOut: (int) sleepTimeOut {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    config.sleepTimeout = sleepTimeOut;
    return self;
}

- (RudderConfig*) build {
    if (config == nil) {
        config = [[RudderConfig alloc] init];
    }
    return config;
}
@end
