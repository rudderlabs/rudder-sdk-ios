//
//  RudderNetwork.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderNetwork : NSObject

- (NSDictionary<NSString* , NSObject *>*) dict;

@property (nonatomic, readwrite) NSString* carrier;
@property (nonatomic, readwrite) bool wifi;
@property (nonatomic, readwrite) bool bluetooth;
@property (nonatomic, readwrite) bool cellular;

@end

NS_ASSUME_NONNULL_END
