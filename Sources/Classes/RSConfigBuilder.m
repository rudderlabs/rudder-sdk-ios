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
#import "RSUtils.h"

@implementation RSConfigBuilder

- (instancetype) withEndPointUrl:(NSString *) endPointUrl{
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    NSURL *url = [[NSURL alloc] initWithString:endPointUrl];
    if([RSUtils isValidURL:url]) {
        config.dataPlaneUrl = [RSUtils appendSlashToUrl: url.absoluteString];
    }
    return self;
}

- (instancetype) withDataPlaneUrl: (NSString*) dataPlaneUrl {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    if (dataPlaneUrl == nil)
        return self;
    
    NSURL *url = [[NSURL alloc] initWithString:dataPlaneUrl];
    if([RSUtils isValidURL:url]) {
        config.dataPlaneUrl = [RSUtils appendSlashToUrl: url.absoluteString];
    }
    return self;
}

- (instancetype)withDataPlaneURL:(NSURL *) dataPlaneURL {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    if([RSUtils isValidURL:dataPlaneURL]) {
        config.dataPlaneUrl = [RSUtils appendSlashToUrl: dataPlaneURL.absoluteString];
    }
    return self;
}

- (instancetype) withDataResidencyServer:(RSDataResidencyServer) dataResidencyServer {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.dataResidencyServer = dataResidencyServer;
    return self;
}

- (instancetype) withFlushQueueSize: (int) flushQueueSize {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    if (flushQueueSize < 1 || flushQueueSize > 100) {
        return self;
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

- (instancetype)withConsentFilter:(id <RSConsentFilter> _Nonnull)consentFilter {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.consentFilter = consentFilter;
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

- (instancetype) withEnableBackgroundMode:(BOOL)enableBackgroundMode {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.enableBackgroundMode = enableBackgroundMode;
    return self;
}

-(instancetype)withConfigPlaneUrl:(NSString *) configPlaneUrl {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    NSURL *url = [[NSURL alloc] initWithString:configPlaneUrl];
    if([RSUtils isValidURL:url]) {
        config.controlPlaneUrl = [RSUtils appendSlashToUrl: url.absoluteString];
    }
    return self;
}

- (instancetype)withControlPlaneUrl:(NSString *) controlPlaneUrl {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    if (controlPlaneUrl == nil)
        return self;
    
    NSURL *url = [[NSURL alloc] initWithString:controlPlaneUrl];
    if([RSUtils isValidURL:url]) {
        config.controlPlaneUrl = [RSUtils appendSlashToUrl: url.absoluteString];
    }
    return self;
}

- (instancetype)withControlPlaneURL:(NSURL *) controlPlaneURL {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    if([RSUtils isValidURL:controlPlaneURL]) {
        config.controlPlaneUrl = [RSUtils appendSlashToUrl: controlPlaneURL.absoluteString];
    }
    return self;
}

- (instancetype)withAutoSessionTracking:(BOOL)autoSessionTracking {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.automaticSessionTracking = autoSessionTracking;
    return self;
}

- (instancetype)withSessionTimeoutMillis:(long)sessionTimeout {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    if (sessionTimeout < RSSessionInActivityMinTimeOut) {
        config.sessionInActivityTimeOut = RSSessionInActivityDefaultTimeOut;
        return self;
    }
    config.sessionInActivityTimeOut = sessionTimeout;
    return self;
}

- (instancetype)withGzip:(BOOL)status {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.gzip = status;
    return self;
}

- (instancetype) withCollectDeviceId: (BOOL) collectDeviceId {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.collectDeviceId = collectDeviceId;
    return self;
}

- (instancetype)withDBEncryption:(RSDBEncryption *)dbEncryption {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    config.dbEncryption = dbEncryption;
    return self;
}

- (RSConfig*) build {
    if (config == nil) {
        config = [[RSConfig alloc] init];
    }
    return config;
}
@end
