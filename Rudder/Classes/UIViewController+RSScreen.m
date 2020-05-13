//
//  UIViewController+RSScreen.m
//  RSSDKCore
//
//  Created by Arnab Pal on 13/02/20.
//

#import "UIViewController+RSScreen.h"
#import "RSLogger.h"
#import "RSClient.h"
#import <objc/runtime.h>

@implementation UIViewController (RSScreen)

+ (void)rudder_swizzleView {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        SEL originalSelector = @selector(viewDidAppear:);
        SEL swizzledSelector = @selector(rudder_viewDidAppear:);

        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

        BOOL didAddMethod =
            class_addMethod(class,
                            originalSelector,
                            method_getImplementation(swizzledMethod),
                            method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

+ (UIViewController*) rudder_topViewController {
    UIViewController *top = [UIApplication sharedApplication].delegate.window.rootViewController;
    return [self rudder_topViewController:top];
}

+ (UIViewController *)rudder_topViewController:(UIViewController *)rootViewController
{
    UIViewController *nextRootViewController = [self rudder_nextRootViewController:rootViewController];
    if (nextRootViewController) {
        return [self rudder_topViewController:nextRootViewController];
    }

    return rootViewController;
}

+ (UIViewController *)rudder_nextRootViewController:(UIViewController *)rootViewController
{
    UIViewController *presentedViewController = rootViewController.presentedViewController;
    if (presentedViewController != nil) {
        return presentedViewController;
    }

    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *lastViewController = ((UINavigationController *)rootViewController).viewControllers.lastObject;
        return lastViewController;
    }

    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        __auto_type *currentTabViewController = ((UITabBarController*)rootViewController).selectedViewController;
        if (currentTabViewController != nil) {
            return currentTabViewController;
        }
    }

    if (rootViewController.childViewControllers.count > 0) {
        // fall back on first child UIViewController as a "best guess" assumption
        __auto_type *firstChildViewController = rootViewController.childViewControllers.firstObject;
        if (firstChildViewController != nil) {
            return firstChildViewController;
        }
    }

    return nil;
}

- (void) rudder_viewDidAppear: (BOOL) animated {
    UIViewController *topViewController = [[self class] rudder_topViewController];
    
    NSString *name = [topViewController title];
    if (!name || name.length == 0) {
        name = [[[topViewController class] description] stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
        // Class name could be just "ViewController".
        if (name.length == 0) {
            [RSLogger logWarn:@"Couldn't get the screen name"];
            name = @"Unknown";
        }
    }
    
    [[RSClient sharedInstance] screen:name properties:@{@"automatic": [[NSNumber alloc] initWithBool:YES], @"name": name}];

    [self rudder_viewDidAppear:animated];
}

@end
