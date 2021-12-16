//
//  WKInterfaceController+RSScreen.m
//  RSSDKCore
//
//  Created by Desu Sai Venkat on 15/12/21.
//

#if TARGET_OS_WATCH

#import "WKInterfaceController+RSScreen.h"
#import "RSLogger.h"
#import "RSClient.h"
#import <objc/runtime.h>

@implementation WKInterfaceController (RSScreen)

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

- (void) rudder_viewDidAppear: (BOOL) animated {
    NSString *name = [[self class] description];
    if (name == nil) {
        [RSLogger logWarn:@"Couldn't get the screen name"];
        name = @"Unknown";
    }
    name = [name stringByReplacingOccurrencesOfString:@"ViewController" withString:@""];
    [[RSClient sharedInstance] screen:name properties:@{@"automatic": [[NSNumber alloc] initWithBool:YES], @"name": name}];

    [self rudder_viewDidAppear:animated];
}

@end

#endif
