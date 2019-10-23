//
//  RudderElementCache.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderElementCache.h"

static RudderContext* context;

@implementation RudderElementCache

+ (void)initiate {
    if (context == nil) {
        context = [[RudderContext alloc] init];
    }
}

+ (RudderContext *)getContext {
    return context;
}

+ (void)updateTraits:(RudderTraits *)traits {
    context.traits = traits;
}

@end
