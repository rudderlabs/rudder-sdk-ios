//
//  RudderScreenInfo.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderScreenInfo : NSObject

- (NSDictionary<NSString* , NSObject *>*) dict;

@property (nonatomic, readwrite) int density;
@property (nonatomic, readwrite) int width;
@property (nonatomic, readwrite) int height;

@end

NS_ASSUME_NONNULL_END
