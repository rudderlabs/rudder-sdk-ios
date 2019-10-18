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

@interface RudderConfigBuilder : NSObject  {
    RudderConfig *config;
}

- (instancetype) withEndPointUrl: (NSString*) endPointUrl;
- (instancetype) withFlushQueueSize: (int) flushQueueSize;
- (instancetype) withDebug: (BOOL) debug;
- (instancetype) withLoglevel: (int) logLevel;
- (instancetype) withDBThreshold: (int) dbThreshold;
- (instancetype) withSleepTimeOut: (int) sleepTimeOut;
- (RudderConfig*) build;

@end

NS_ASSUME_NONNULL_END
