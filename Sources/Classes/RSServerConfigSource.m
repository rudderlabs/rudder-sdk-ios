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

- (NSString *_Nullable) getDataResidencyUrl:(RSDataResidencyServer) residency {
    NSArray * residenceDataPlanes;
    switch(residency) {
        case EU:
            residenceDataPlanes = [self.dataPlanes objectForKey:@"EU"];
        // If EU is missing from the sourceConfig response we should fallback to the US, hence the break is not added here.
        default:
            if (residenceDataPlanes != nil)
                break;
            residenceDataPlanes = [self.dataPlanes objectForKey:@"US"];
    }
    
    if(residenceDataPlanes == nil || [residenceDataPlanes count] == 0)
        return nil;
    for (NSDictionary* residenceDataPlane in residenceDataPlanes) {
        if([[residenceDataPlane objectForKey:@"default"] boolValue]) {
            return [residenceDataPlane objectForKey:@"url"];
        }
    }
    return nil;
}

@end
