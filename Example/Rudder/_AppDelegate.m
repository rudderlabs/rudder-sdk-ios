//
//  _AppDelegate.m
//  Rudder
//
//  Created by arnabp92 on 02/26/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

#import "_AppDelegate.h"
#import <Rudder/Rudder.h>

static NSString *DATA_PLANE_URL = @"https://c2de320e.ngrok.io";
static NSString *WRITE_KEY = @"1ZTkZgCMnZyXeWsFbcjGsOx4jnv";
//static WKWebView *webView;

@implementation _AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    RudderConfigBuilder *builder = [[RudderConfigBuilder alloc] init];
    [builder withDataPlaneUrl:DATA_PLANE_URL];
    [builder withLoglevel:RudderLogLevelDebug];
    [builder withTrackLifecycleEvens:YES];
    [builder withRecordScreenViews:YES];
    [RudderClient getInstance:WRITE_KEY config:[builder build]];
    
    [[[RudderClient sharedInstance] getContext] putDeviceToken:[self getDeviceToken]];
    
//    webView = [[WKWebView alloc] initWithFrame:CGRectZero];
//    [webView loadHTMLString:@"<html></html>" baseURL:nil];
//
//    [webView evaluateJavaScript:@"navigator.appName" completionHandler:^(id __nullable appName, NSError * __nullable error) {
//        NSLog(@"======================= : %@", appName);
//        NSLog(@"======================= : %@", [error localizedDescription]);
//        // Netscape
//    }];
//
//    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id __nullable userAgent, NSError * __nullable error) {
//        NSLog(@"======================= : %@", userAgent);
//        NSLog(@"======================= : %@", [error localizedDescription]);
//        // iOS 8.3
//        // Mozilla/5.0 (iPhone; CPU iPhone OS 8_3 like Mac OS X) AppleWebKit/600.1.4 (KHTML, like Gecko) Mobile/12F70
//        // iOS 9.0
//        // Mozilla/5.0 (iPhone; CPU iPhone OS 9_0 like Mac OS X) AppleWebKit/601.1.32 (KHTML, like Gecko) Mobile/13A4254v
//    }];
    
    return YES;
}

- (NSString*) getDeviceToken {
    return @"example_device_token";
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
