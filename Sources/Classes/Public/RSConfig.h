//
//  RSConfig.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSIntegrationFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSConfig : NSObject

@property (nonatomic, nonnull) NSString *dataPlaneUrl;
@property (nonatomic) int flushQueueSize;
@property (nonatomic) int dbCountThreshold;
@property (nonatomic) int sleepTimeout;
@property (nonatomic) int logLevel;
@property (nonatomic) int configRefreshInterval;
@property (nonatomic) bool trackLifecycleEvents;
@property (nonatomic) bool recordScreenViews;
@property (nonatomic) bool enableBackgroundMode;
@property (nonatomic, nonnull) NSString *controlPlaneUrl;
@property (nonatomic, readwrite) NSMutableArray* factories;
@property (nonatomic, readwrite) NSMutableArray* customFactories;

@end

NS_ASSUME_NONNULL_END
