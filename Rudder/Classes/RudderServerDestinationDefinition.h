//
//  RudderServerDestinationDefinition.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderServerDestinationDefinition : NSObject

@property (nonatomic, readwrite) NSString* definitionName;
@property (nonatomic, readwrite) NSString* displayName;
@property (nonatomic, readwrite) NSString* updatedAt;

@end

NS_ASSUME_NONNULL_END
