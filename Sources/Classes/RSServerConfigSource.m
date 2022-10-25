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

- (void) addDataResidencyUrl:(NSString *) url forResidency:(DataResidencyServer) residency {
    [self.dataResidencyUrls setValue:url forKey:@(residency)];
}

- (NSString *) getDataResidencyUrl:(DataResidencyServer) residency {
    if([self.dataResidencyUrls objectForKey:@(residency)]) {
        return [self.dataResidencyUrls objectForKey:@(residency)];
    }
    // defaulted to US
    return [self.dataResidencyUrls objectForKey:@(US)];
}

@end
