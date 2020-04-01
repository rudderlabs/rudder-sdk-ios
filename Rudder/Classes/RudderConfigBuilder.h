//
//  RudderConfigBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderConfig.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RudderIntegrationFactory;
@class RudderConfig;

@interface RudderConfigBuilder : NSObject  {
    RudderConfig *config;
}

- (instancetype) withEndPointUrl : (NSString*) endPointUrl __attribute((deprecated("Use withDataPlaneUrl instead.")));
- (instancetype) withDataPlaneUrl: (NSString*) dataPlaneUrl;
- (instancetype) withFlushQueueSize: (int) flushQueueSize;
- (instancetype) withDebug: (BOOL) debug;
- (instancetype) withLoglevel: (int) logLevel;
- (instancetype) withDBCountThreshold: (int) dbCountThreshold;
- (instancetype) withSleepTimeOut: (int) sleepTimeOut;
- (instancetype) withConfigRefreshInteval: (int) configRefreshInterval;
- (instancetype) withTrackLifecycleEvens: (BOOL) trackLifecycleEvents;
- (instancetype) withRecordScreenViews: (BOOL) recordScreenViews;
- (instancetype) withConfigPlaneUrl: (NSString*) configPlaneUrl __attribute((deprecated("Use withControlPlaneUrl instead.")));
- (instancetype) withControlPlaneUrl: (NSString*) controlPlaneUrl;
- (instancetype) withFactory: (id <RudderIntegrationFactory> _Nonnull) factory;
- (RudderConfig*) build;

@end

NS_ASSUME_NONNULL_END
