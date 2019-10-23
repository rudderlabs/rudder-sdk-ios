//
//  RudderServerDestination.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderServerDestinationDefinition.h"

NS_ASSUME_NONNULL_BEGIN

@interface RudderServerDestination : NSObject

@property (nonatomic, readwrite) NSString* destinationId;
@property (nonatomic, readwrite) NSString* destinationName;
@property (nonatomic, readwrite) BOOL isDestinationEnabled;
@property (nonatomic, readwrite) NSString* updatedAt;
@property (nonatomic, readwrite) RudderServerDestinationDefinition* destinationDefinition;
@property (nonatomic, readwrite) NSDictionary* destinationConfig;

@end

NS_ASSUME_NONNULL_END
