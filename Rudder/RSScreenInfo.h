//
//  RSScreenInfo.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#if !TARGET_OS_WATCH
#import <UIKit/UIKit.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface RSScreenInfo : NSObject

- (NSDictionary<NSString* , NSObject *>*) dict;

@property (nonatomic, readwrite) int density;
@property (nonatomic, readwrite) int width;
@property (nonatomic, readwrite) int height;

@end

NS_ASSUME_NONNULL_END
