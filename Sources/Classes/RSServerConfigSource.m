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
        self.dataPlanes = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addDestination:(RSServerDestination *)destination {
    [self.destinations addObject:destination];
}

- (NSString *) getDataResidencyUrl:(RSDataResidencyServer) residency {
    NSArray * residenceDataPlanes;
    switch(residency) {
        case EU:
            residenceDataPlanes = [self.dataPlanes objectForKey:@"EU"];
        default:
            if (residenceDataPlanes != nil)
                break;
            residenceDataPlanes = [self.dataPlanes objectForKey:@"US"];
    }
    
    if(residenceDataPlanes == nil)
        return nil;
    for (NSDictionary* residenceDataPlane in residenceDataPlanes) {
        if([[residenceDataPlane objectForKey:@"default"] boolValue]) {
            NSLog(@"Data type is %@",[[residenceDataPlane objectForKey:@"default"] class]);
            return [residenceDataPlane objectForKey:@"url"];
        }
    }
    return nil;
}

@end
