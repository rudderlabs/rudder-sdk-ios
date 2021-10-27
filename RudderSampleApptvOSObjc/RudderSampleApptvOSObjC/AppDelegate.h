//
//  AppDelegate.h
//  Sample-tvOS
//
//  Created by Desu Sai Venkat on 18/10/21.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
+ (void) identify;
+ (void) track;
+ (void) reset;
+ (void) optIn;
+ (void) optOut;
+ (void) screen;


@end

