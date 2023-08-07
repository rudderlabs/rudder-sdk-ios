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

- (instancetype)initWithConfigDict:(NSDictionary *)sourceConfigDict {
    self = [super init];
    if (self) {
        NSDictionary *sourceDict = [sourceConfigDict objectForKey:@"source"];
        NSString *sourceId = [sourceDict objectForKey:@"id"];
        NSString *sourceName = [sourceDict objectForKey:@"name"];
        NSNumber *sourceEnabled = [sourceDict valueForKey:@"enabled"];
        NSDictionary *configDict = [sourceDict objectForKey:@"config"];
        BOOL isErrorsCollectionEnabled = NO;
        BOOL isMetricsCollectionEnabled = NO;
        if (configDict) {
            NSDictionary *statsCollection = [configDict objectForKey:@"statsCollection"];
            NSDictionary *errors = [statsCollection objectForKey:@"errors"];
            NSNumber *isErrorsEnabled = [errors valueForKey:@"enabled"];
            NSDictionary *metrics = [statsCollection objectForKey:@"metrics"];
            NSNumber *isMetricsEnabled = [metrics valueForKey:@"enabled"];
            isErrorsCollectionEnabled = [isErrorsEnabled boolValue];
            isMetricsCollectionEnabled = [isMetricsEnabled boolValue];
        }
        BOOL isSourceEnabled = NO;
        if (sourceEnabled != nil) {
            isSourceEnabled = [sourceEnabled boolValue];
        }
        NSString *updatedAt = [sourceDict objectForKey:@"updatedAt"];
        self.sourceId = sourceId;
        self.sourceName = sourceName;
        self.isSourceEnabled = isSourceEnabled;
        self.updatedAt = updatedAt;
        self.isErrorsCollectionEnabled = isErrorsCollectionEnabled;
        self.isMetricsCollectionEnabled = isMetricsCollectionEnabled;
        
        NSArray *destinationArr = [sourceDict objectForKey:@"destinations"];
        NSMutableArray<RSServerDestination *> *destinations = [[NSMutableArray alloc] init];
        for (NSDictionary* destinationDict in destinationArr) {
            // create destination object
            RSServerDestination *destination = [[RSServerDestination alloc] init];
            destination.destinationId = [destinationDict objectForKey:@"id"];
            destination.destinationName = [destinationDict objectForKey:@"name"];
            NSNumber *destinationEnabled = [destinationDict objectForKey:@"enabled"];
            BOOL isDestinationEnabled = NO;
            if (destinationEnabled != nil) {
                isDestinationEnabled = [destinationEnabled boolValue];
            }
            destination.isDestinationEnabled = isDestinationEnabled;
            destination.updatedAt = [destinationDict objectForKey:@"updatedAt"];
            
            // checking if transformations are connected for each device mode destination, and if connected storing their id's in an array
            NSNumber *_shouldApplyDeviceModeTransformation = [destinationDict objectForKey:@"shouldApplyDeviceModeTransformation"];
            BOOL shouldApplyDeviceModeTransformation = NO;
            if (_shouldApplyDeviceModeTransformation != nil) {
                shouldApplyDeviceModeTransformation = [_shouldApplyDeviceModeTransformation boolValue];
            }
            destination.shouldApplyDeviceModeTransformation = shouldApplyDeviceModeTransformation;
            
            NSNumber *_propagateEventsUntransformedOnError = [destinationDict objectForKey:@"propagateEventsUntransformedOnError"];
            BOOL propagateEventsUntransformedOnError = NO;
            if (_propagateEventsUntransformedOnError != nil) {
                propagateEventsUntransformedOnError = [_propagateEventsUntransformedOnError boolValue];
            }
            destination.propagateEventsUntransformedOnError = propagateEventsUntransformedOnError;
            
            RSServerDestinationDefinition *destinationDefinition = [[RSServerDestinationDefinition alloc] init];
            NSDictionary *definitionDict = [destinationDict objectForKey:@"destinationDefinition"];
            destinationDefinition.definitionName = [definitionDict objectForKey:@"name"];
            destinationDefinition.displayName = [definitionDict objectForKey:@"displayName"];
            destinationDefinition.updatedAt = [definitionDict objectForKey:@"updatedAt"];
            destination.destinationDefinition = destinationDefinition;
            
            destination.destinationConfig = [destinationDict objectForKey:@"config"];
            [destinations addObject:destination];
        }
        
        self.dataPlanes = [sourceDict objectForKey:@"dataplanes"];
        self.destinations = destinations;
    }
    return self;
}

@end
