//
//  UIViewController+RSScreen.h
//  RSSDKCore
//
//  Created by Arnab Pal on 13/02/20.
//
#include <TargetConditionals.h>

#if TARGET_OS_IOS || TARGET_OS_TV

#import <UIKit/UIKit.h>

@interface UIViewController (RSScreen)

+ (void) rudder_swizzleView;

@end

#endif
