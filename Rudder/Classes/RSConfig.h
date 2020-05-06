//
//  RudderConfig.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderIntegrationFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface RudderConfig : NSObject

@property (nonatomic, nonnull) NSString *dataPlaneUrl;
@property (nonatomic) int flushQueueSize;
@property (nonatomic) int dbCountThreshold;
@property (nonatomic) int sleepTimeout;
@property (nonatomic) int logLevel;
@property (nonatomic) int configRefreshInterval;
@property (nonatomic) bool trackLifecycleEvents;
@property (nonatomic) bool recordScreenViews;
@property (nonatomic, nonnull) NSString *controlPlaneUrl;
@property (nonatomic, readwrite) NSMutableArray* factories;

@end

NS_ASSUME_NONNULL_END
