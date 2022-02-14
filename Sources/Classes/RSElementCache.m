//
//  RSElementCache.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSElementCache.h"

static RSContext* cachedContext;

@implementation RSElementCache

+ (void)initiate {
    if (cachedContext == nil) {
        cachedContext = [[RSContext alloc] init];
    }
}

+ (RSContext *)getContext {
    return [cachedContext copy];
}

+ (void)updateTraits:(RSTraits *)traits {
    dispatch_async([RSContext getQueue], ^{
        [cachedContext updateTraits:traits];
        [self persistTraits];
    });
}

+ (void)persistTraits {
    [cachedContext persistTraits];
}

+ (void) reset {
    dispatch_async([RSContext getQueue], ^{
        [cachedContext resetTraits];
        [cachedContext persistTraits];
        [cachedContext resetExternalIds];
    });
}

+ (void)updateTraitsDict:(NSMutableDictionary<NSString *,NSObject *> *)traitsDict {
    dispatch_async([RSContext getQueue], ^{
        [cachedContext updateTraitsDict: traitsDict];
        [self persistTraits];
    });
}

+(void) updateTraitsAnonymousId {
    dispatch_async([RSContext getQueue], ^{
        [cachedContext updateTraitsAnonymousId];
        [self persistTraits];
    });
}

+ (NSString *)getAnonymousId {
    return [[RSPreferenceManager getInstance] getAnonymousId];
}

+ (void) updateExternalIds:(NSMutableArray *)externalIds {
   dispatch_async([RSContext getQueue], ^{
        [cachedContext updateExternalIds:externalIds];
        [cachedContext persistExternalIds];
    });
}
@end
