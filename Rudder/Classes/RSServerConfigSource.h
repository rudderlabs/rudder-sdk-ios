//
//  RSServerConfigSource.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSServerDestination.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSServerConfigSource : NSObject 

@property (nonatomic, readwrite) NSString *sourceId;
@property (nonatomic, readwrite) NSString *sourceName;
@property (nonatomic, readwrite) BOOL isSourceEnabled;
@property (nonatomic, readwrite) NSString *updatedAt;
@property (nonatomic, readwrite) NSMutableArray *destinations;

- (void) addDestination: (RSServerDestination*) destination;

@end

NS_ASSUME_NONNULL_END
