//
//  AppDelegate.m
//  Sample-tvOS
//
//  Created by Desu Sai Venkat on 18/10/21.
//

#import "AppDelegate.h"
#import <Rudder/Rudder.h>

@interface AppDelegate ()

@end

static NSString *DATA_PLANE_URL = @"https://9de5-175-101-36-4.ngrok.io";
static NSString *WRITE_KEY = @"1pcZviVxgjd3rTUUmaTUBinGH0A";


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
        RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
        [builder withDataPlaneURL:[[NSURL alloc] initWithString:DATA_PLANE_URL]];
        [builder withLoglevel:RSLogLevelDebug];
        [builder withTrackLifecycleEvens:YES];
        [builder withRecordScreenViews:YES];
        // creating the client object by passing the options object
        [RSClient getInstance:WRITE_KEY config:[builder build]];
        
        [[RSClient sharedInstance] track:@"simple_track_event"];
        [[RSClient sharedInstance] track:@"simple_track_with_props" properties:@{
            @"key_1" : @"value_1",
            @"key_2" : @"value_2"
        } options:nil];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


@end
