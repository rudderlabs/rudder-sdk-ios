//
//  RudderOSInfo.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderOSInfo : NSObject

- (NSDictionary<NSString* , NSObject *>*) dict;

@property (nonatomic, readwrite) NSString* name;
@property (nonatomic, readwrite) NSString* version;

@end

NS_ASSUME_NONNULL_END
