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

+ (void)initiateWithConfig:(RSConfig *) config {
    if (cachedContext == nil) {
        cachedContext = [[RSContext alloc] initWithConfig:config];
    }
}

+ (RSContext *)getContext {
    return [cachedContext copy];
}

+ (void)updateTraits:(RSTraits *)traits {
    [cachedContext updateTraits:traits];
    [self persistTraits];
}


+ (void)persistTraits {
    [cachedContext persistTraitsOnQueue];
}

+ (void) reset {
    [cachedContext resetTraits];
    [cachedContext persistTraitsOnQueue];
    [cachedContext resetExternalIdsOnQueue];
}

+ (void)updateTraitsDict:(NSMutableDictionary<NSString *,NSObject *> *)traitsDict {
    [cachedContext updateTraitsDict: traitsDict];
    [self persistTraits];
}

+ (void) updateTraitsAnonymousId {
    [cachedContext updateTraitsAnonymousId];
    [self persistTraits];
}

+ (NSString *)getAnonymousId {
    return [[RSPreferenceManager getInstance] getAnonymousId];
}

+ (void) updateExternalIds:(NSMutableArray *)externalIds {
    [cachedContext updateExternalIds:externalIds];
    [cachedContext persistExternalIds];
}
@end
