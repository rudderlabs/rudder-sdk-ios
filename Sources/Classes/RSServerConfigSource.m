//
//  RSServerConfigSource.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSServerConfigSource.h"

@implementation RSServerConfigSource

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.destinations = [[NSMutableArray alloc] init];
        self.dataResidencyUrls = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addDestination:(RSServerDestination *)destination {
    [self.destinations addObject:destination];
}

- (NSString *) getDataResidencyUrl:(RSDataResidencyServer) residency {
    switch(residency) {
        case EU:
            if([self.dataResidencyUrls objectForKey:@"eu"] != nil) {
                return [self.dataResidencyUrls objectForKey:@"eu"];
            }
        default:
            return [self.dataResidencyUrls objectForKey:@"us"];
    }
}

@end
