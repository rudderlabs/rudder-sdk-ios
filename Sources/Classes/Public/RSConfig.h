//
//  RSConfig.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSIntegrationFactory.h"
#import "RSEnums.h"
#import "RSConsentFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSConfig : NSObject

@property (nonatomic, nullable) NSString *dataPlaneUrl;
@property (nonatomic) RSDataResidencyServer dataResidencyServer;
@property (nonatomic) int flushQueueSize;
@property (nonatomic) int dbCountThreshold;
@property (nonatomic) int sleepTimeout;
@property (nonatomic) int logLevel;
@property (nonatomic) int configRefreshInterval;
@property (nonatomic) long sessionInActivityTimeOut;
@property (nonatomic) bool trackLifecycleEvents;
@property (nonatomic) bool recordScreenViews;
@property (nonatomic) bool enableBackgroundMode;
@property (nonatomic) bool automaticSessionTracking;
@property (nonatomic, nonnull) NSString *controlPlaneUrl;
@property (nonatomic, readwrite) NSMutableArray* factories;
@property (nonatomic, readwrite) NSMutableArray* customFactories;
@property (nonatomic, readwrite, nullable) id<RSConsentFilter> consentFilter;

@end

NS_ASSUME_NONNULL_END
