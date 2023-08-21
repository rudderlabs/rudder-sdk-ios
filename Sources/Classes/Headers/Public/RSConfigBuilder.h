//
//  RSConfigBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSConfig.h"
#import "RSEnums.h"
#import "RSConsentFilter.h"
#import "RSDBEncryption.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RSIntegrationFactory;
@class RSConfig;

@interface RSConfigBuilder : NSObject  {
    RSConfig *config;
}

- (instancetype)withEndPointUrl:(NSString*)endPointUrl __attribute((deprecated("Use withDataPlaneUrl instead.")));
- (instancetype)withDataPlaneUrl:(NSString* __nullable)dataPlaneUrl;
- (instancetype)withDataPlaneURL:(NSURL*)dataPlaneURL;
- (instancetype)withDataResidencyServer:(RSDataResidencyServer) dataResidencyServer;
- (instancetype)withFlushQueueSize:(int)flushQueueSize;
- (instancetype)withDebug:(BOOL)debug;
- (instancetype)withLoglevel:(int)logLevel;
- (instancetype)withDBCountThreshold:(int)dbCountThreshold;
- (instancetype)withSleepTimeOut:(int)sleepTimeOut;
- (instancetype)withSessionTimeoutMillis:(long)sessionTimeout;
- (instancetype)withConfigRefreshInteval:(int)configRefreshInterval;
- (instancetype)withTrackLifecycleEvens:(BOOL)trackLifecycleEvents;
- (instancetype)withRecordScreenViews:(BOOL)recordScreenViews;
- (instancetype)withEnableBackgroundMode:(BOOL)enableBackgroundMode;
- (instancetype)withAutoSessionTracking:(BOOL)autoSessionTracking;
- (instancetype)withConfigPlaneUrl:(NSString*)configPlaneUrl __attribute((deprecated("Use withControlPlaneUrl instead.")));
- (instancetype)withControlPlaneUrl:(NSString*)controlPlaneUrl;
- (instancetype)withControlPlaneURL:(NSURL*)controlPlaneURL;
- (instancetype)withFactory:(id <RSIntegrationFactory> _Nonnull)factory;
- (instancetype)withCustomFactory:(id <RSIntegrationFactory> _Nonnull)customFactory;
- (instancetype)withConsentFilter:(id <RSConsentFilter> _Nonnull)consentFilter;
- (instancetype) withCollectDeviceId: (BOOL) collectDeviceId;
- (instancetype)withGzip:(BOOL)status;
- (instancetype)withDBEncryption:(RSDBEncryption *)dbEncryption;
- (RSConfig*)build;

@end

NS_ASSUME_NONNULL_END
