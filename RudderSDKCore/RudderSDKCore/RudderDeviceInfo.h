//
//  RudderDeviceInfo.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderDeviceInfo : NSObject

- (NSDictionary<NSString* , NSObject *>*) dict;

@property (nonatomic, readwrite) NSString* identifier;
@property (nonatomic, readwrite) NSString* manufacturer;
@property (nonatomic, readwrite) NSString* model;
@property (nonatomic, readwrite) NSString* name;

@end

NS_ASSUME_NONNULL_END
