//
//  RudderServerConfigSource.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderServerConfigSource.h"

@implementation RudderServerConfigSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.destinations = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addDestination:(RudderServerDestination *)destination {
    [self.destinations addObject:destination];
}

@end
