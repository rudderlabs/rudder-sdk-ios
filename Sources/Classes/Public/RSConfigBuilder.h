//
//  RSConfigBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSConfig.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RSIntegrationFactory;
@class RSConfig;

@interface RSConfigBuilder : NSObject  {
    RSConfig *config;
}

- (instancetype) withEndPointUrl : (NSString*) endPointUrl __attribute((deprecated("Use withDataPlaneUrl instead.")));
- (instancetype) withDataPlaneUrl: (NSString*) dataPlaneUrl;
- (instancetype) withDataPlaneURL: (NSURL*) dataPlaneURL;
- (instancetype) withFlushQueueSize: (int) flushQueueSize;
- (instancetype) withDebug: (BOOL) debug;
- (instancetype) withLoglevel: (int) logLevel;
- (instancetype) withDBCountThreshold: (int) dbCountThreshold;
- (instancetype) withSleepTimeOut: (int) sleepTimeOut;
- (instancetype) withConfigRefreshInteval: (int) configRefreshInterval;
- (instancetype) withTrackLifecycleEvens: (BOOL) trackLifecycleEvents;
- (instancetype) withRecordScreenViews: (BOOL) recordScreenViews;
- (instancetype) withEnableBackgroundMode:(BOOL) enableBackgroundMode;
- (instancetype) withConfigPlaneUrl: (NSString*) configPlaneUrl __attribute((deprecated("Use withControlPlaneUrl instead.")));
- (instancetype) withControlPlaneUrl: (NSString*) controlPlaneUrl;
- (instancetype) withControlPlaneURL: (NSURL*) controlPlaneURL;
- (instancetype) withFactory: (id <RSIntegrationFactory> _Nonnull) factory;
- (instancetype) withCustomFactory: (id <RSIntegrationFactory> _Nonnull) customFactory;
- (RSConfig*) build;

@end

NS_ASSUME_NONNULL_END
