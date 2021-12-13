//
//  RSElementCache.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSElementCache.h"

static RSContext* cachedContext;
static dispatch_queue_t queue;

@implementation RSElementCache

+ (void)initiate {
    if (cachedContext == nil) {
        cachedContext = [[RSContext alloc] init];
    }
    if (queue == nil) {
        queue = dispatch_queue_create("com.rudder.MyQueue", NULL);
    }
}

+ (RSContext *)getContext {
    return [cachedContext copy];
}

+ (void)updateTraits:(RSTraits *)traits {
    dispatch_async(queue, ^{
        [cachedContext updateTraits:traits];
        [self persistTraits];
    });
    
}

+ (void)persistTraits {
    dispatch_async(queue, ^{
        [cachedContext persistTraits];
    });
}

+ (void) reset {
    dispatch_async(queue, ^{
        [cachedContext resetTraits];
        [cachedContext persistTraits];
        [cachedContext resetExternalIds];
    });
}

+ (void)updateTraitsDict:(NSMutableDictionary<NSString *,NSObject *> *)traitsDict {
    dispatch_async(queue, ^{
        [cachedContext updateTraitsDict: traitsDict];
        [self persistTraits];
    });
}

+(void) updateTraitsAnonymousId {
    dispatch_async(queue, ^{
        [cachedContext updateTraitsAnonymousId];
        [self persistTraits];
    });
}

+ (NSString *)getAnonymousId {
    return [[RSPreferenceManager getInstance] getAnonymousId];
}

+ (void) updateExternalIds:(NSMutableArray *)externalIds {
    dispatch_async(queue, ^{
        [cachedContext updateExternalIds:externalIds];
        [cachedContext persistExternalIds];
    });
}
@end
