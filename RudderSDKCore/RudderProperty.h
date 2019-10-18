//
//  RudderProperty.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderProperty : NSObject

@property (nonatomic, readwrite) NSDictionary<NSString*, NSObject*>* propertyDict;

@end

NS_ASSUME_NONNULL_END
