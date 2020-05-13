//
//  RSServerDestinationDefinition.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSServerDestinationDefinition : NSObject

@property (nonatomic, readwrite) NSString* definitionName;
@property (nonatomic, readwrite) NSString* displayName;
@property (nonatomic, readwrite) NSString* updatedAt;

@end

NS_ASSUME_NONNULL_END
