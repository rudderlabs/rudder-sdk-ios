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
    [cachedContext updateTraits:traits];
}

+ (void)persistTraits {
    [cachedContext persistTraits];
}

+ (void) reset {
    [cachedContext updateTraits:nil];
    [cachedContext persistTraits];
    [cachedContext updateExternalIds:nil];
}

+ (void)updateTraitsDict:(NSMutableDictionary<NSString *,NSObject *> *)traitsDict {
    [cachedContext updateTraitsDict: traitsDict];
}

+ (NSString *)getAnonymousId {
    return cachedContext.device.identifier;
}

+ (void) updateExternalIds:(NSMutableArray *)externalId {
    [cachedContext updateExternalIds:externalId];
}
@end
