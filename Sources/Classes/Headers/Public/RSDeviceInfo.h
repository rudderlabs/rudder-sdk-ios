//
//  RSDeviceInfo.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RSConfig;

NS_ASSUME_NONNULL_BEGIN

@interface RSDeviceInfo : NSObject

- (instancetype) initWithConfig: (RSConfig *) config;
- (instancetype) initWithDict:(NSDictionary*) dict;
- (NSDictionary<NSString* , NSObject *>*) dict;

@property (nonatomic, readwrite, nullable) NSString* identifier;
@property (nonatomic, readwrite) NSString* manufacturer;
@property (nonatomic, readwrite) NSString* model;
@property (nonatomic, readwrite) NSString* name;
@property (nonatomic, readwrite) NSString* type;
@property (nonatomic, readwrite) NSString* token;
@property (nonatomic, readwrite) BOOL adTrackingEnabled;
@property (nonatomic, readwrite) NSString* advertisingId;
@property (nonatomic, readwrite) int attTrackingStatus;

@end

NS_ASSUME_NONNULL_END
