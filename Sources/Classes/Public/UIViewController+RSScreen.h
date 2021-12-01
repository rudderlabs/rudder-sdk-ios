//
//  UIViewController+RSScreen.h
//  RSSDKCore
//
//  Created by Arnab Pal on 13/02/20.
//
#if TARGET_OS_IPHONE && !TARGET_OS_WATCH

#import <UIKit/UIKit.h>

@interface UIViewController (RSScreen)

+ (void) rudder_swizzleView;

@end

#endif
