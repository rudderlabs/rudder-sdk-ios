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

+ (NSString*) getAnonymousId;

+ (void) updateTraits : (RudderTraits*) traits;

+ (void) persistTraits;

+ (void) reset;

+ (void) updateTraitsDict: (NSMutableDictionary<NSString*, NSObject*> *) traitsDict;

@end

NS_ASSUME_NONNULL_END
