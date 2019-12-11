//
//  RudderElementCache.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderElementCache.h"

static RudderContext* cachedContext;

@implementation RudderElementCache

+ (void)initiate {
    if (cachedContext == nil) {
        cachedContext = [[RudderContext alloc] init];
    }
}

+ (RudderContext *)getContext {
    return cachedContext;
}

+ (void)updateTraits:(RudderTraits *)traits {
    [cachedContext updateTraits:traits];
}

+ (void)persistTraits {
    [cachedContext persistTraits];
}

+ (void) reset {
    [cachedContext updateTraits:nil];
    [cachedContext persistTraits];
}

+ (void)updateTraitsDict:(NSMutableDictionary<NSString *,NSObject *> *)traitsDict {
    [cachedContext updateTraitsDict: traitsDict];
}


@end
