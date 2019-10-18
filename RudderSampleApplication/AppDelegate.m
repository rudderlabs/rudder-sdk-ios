//
//  AppDelegate.m
//  RudderSampleApplication
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

NSString *writeKey = @"1R3JbxsqWZlbYjJlBxf0ZNWZOH6";
NSString *endPointUrl = @"https://468d731e.ngrok.io";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    RudderConfigBuilder *builder = [[RudderConfigBuilder alloc] init];
    [builder withEndPointUrl: endPointUrl];
    [builder withDebug: YES];
    self._rudderClient = [RudderClient getInstance: writeKey config: [builder build]];
    
    NSLog(@"client initialized");
    
    NSMutableDictionary<NSString*, NSObject*> *propertyDict = [[NSMutableDictionary alloc] init];
    [propertyDict setValue:@"test_value_1" forKey:@"test_key_1"];
    [propertyDict setValue:@"test_value_2" forKey:@"test_key_2"];
    
    RudderMessageBuilder *trackMessageBuilder = [[RudderMessageBuilder alloc] init];
    [trackMessageBuilder setEventName:@"test_event_name"];
    [trackMessageBuilder setPropertyDict:propertyDict];
    [trackMessageBuilder setUserId:@"test_user_id"];
    [self._rudderClient track:[trackMessageBuilder build]];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
