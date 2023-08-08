//
//  RSServerDestination.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSServerDestinationDefinition.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSServerDestination : NSObject

@property (nonatomic, readwrite) NSString* destinationId;
@property (nonatomic, readwrite) NSString* destinationName;
@property (nonatomic, readwrite) BOOL isDestinationEnabled;
@property (nonatomic, readwrite) NSString* updatedAt;
@property (nonatomic, readwrite) RSServerDestinationDefinition* destinationDefinition;
@property (nonatomic, readwrite) NSDictionary* destinationConfig;
@property (nonatomic, readwrite) NSString* transformationId;
@property (nonatomic, readwrite) BOOL shouldApplyDeviceModeTransformation;
@property (nonatomic, readwrite) BOOL propagateEventsUntransformedOnError;

@end

NS_ASSUME_NONNULL_END
