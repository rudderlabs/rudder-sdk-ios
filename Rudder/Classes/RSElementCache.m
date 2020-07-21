//
//  RSElementCache.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSElementCache.h"

static RSContext* cachedContext;
static RSPreferenceManager *preferenceManager;

@implementation RSElementCache

+ (void)initiate {
    if (cachedContext == nil) {
        cachedContext = [[RSContext alloc] init];
        if (cachedContext.getAnonymousId != nil){
           preferenceManager = [RSPreferenceManager getInstance];
            [preferenceManager getAnonymousId];
        }
    }
}

+ (RSContext *)getContext {
    return cachedContext;
}

+ (void)updateTraits:(RSTraits *)traits {
    [cachedContext updateTraits:traits];
}

+ (void)persistTraits {
    [cachedContext persistTraits];
}

+ (void) reset {
    preferenceManager = [RSPreferenceManager getInstance];
    [preferenceManager resetAnonymousId];
    [cachedContext updateTraits:nil];
    [cachedContext persistTraits];
}

+ (void)updateTraitsDict:(NSMutableDictionary<NSString *,NSObject *> *)traitsDict {
    [cachedContext updateTraitsDict: traitsDict];
}

+ (NSString *)getAnonymousId {
    return cachedContext.getAnonymousId;
}


@end
