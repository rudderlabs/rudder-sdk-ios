//
//  _AppDelegate.m
//  Rudder
//
//  Created by arnabp92 on 02/26/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

#import "_AppDelegate.h"
#import <Rudder/Rudder.h>
#import <AdSupport/ASIdentifierManager.h>

static NSString *DATA_PLANE_URL = @"https://22ca4837f6ce.ngrok.io";
static NSString *WRITE_KEY = @"1pcZviVxgjd3rTUUmaTUBinGH0A";

@implementation _AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[RSClient setAnonymousId:@"6a276137-2fe4-4682-a8f7-77f701f63ea0"];
    
    // Override point for customization after application launch.
    RSOption *defaultOption = [[RSOption alloc]init];
    [defaultOption putIntegration:@"Default" isEnabled:@YES];
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
    [builder withDataPlaneURL:[[NSURL alloc] initWithString:DATA_PLANE_URL]];
    [builder withLoglevel:RSLogLevelDebug];
    [builder withTrackLifecycleEvens:NO];
    [builder withRecordScreenViews:NO];
    [RSClient getInstance:WRITE_KEY config:[builder build] options:defaultOption];
    RSOption *option = [[RSOption alloc]init];
    [option putIntegration:@"Amplitude" isEnabled:@YES];
    [option putIntegration:@"MixPanel" isEnabled:@NO];
    [[RSClient sharedInstance] track:@"simple_track_event"];
    [[RSClient sharedInstance] track:@"simple_track_with_props" properties:@{
        @"key_1" : @"value_1",
        @"key_2" : @"value_2"
    } options:option];
    
//    [[[RSClient sharedInstance] getContext] putDeviceToken:[self getDeviceToken]];
//    [[[RSClient sharedInstance] getContext] putAdvertisementId:[self getIDFA]];
    
    return YES;
}

- (NSString*) getIDFA {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
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
