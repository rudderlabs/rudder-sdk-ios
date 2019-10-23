//
//  RudderElementCache.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface RudderElementCache : NSObject

+ (void) initiate;

+ (RudderContext*) getContext;

+ (void) updateTraits : (RudderTraits*) traits;

@end

NS_ASSUME_NONNULL_END
