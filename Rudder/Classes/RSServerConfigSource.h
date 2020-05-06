//
//  RudderServerConfigSource.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderServerDestination.h"

NS_ASSUME_NONNULL_BEGIN

@interface RudderServerConfigSource : NSObject 

@property (nonatomic, readwrite) NSString *sourceId;
@property (nonatomic, readwrite) NSString *sourceName;
@property (nonatomic, readwrite) BOOL isSourceEnabled;
@property (nonatomic, readwrite) NSString *updatedAt;
@property (nonatomic, readwrite) NSMutableArray *destinations;

- (void) addDestination: (RudderServerDestination*) destination;

@end

NS_ASSUME_NONNULL_END
