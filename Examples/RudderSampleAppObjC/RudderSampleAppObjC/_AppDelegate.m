//
//  _AppDelegate.m
//  Rudder
//
//  Created by arnabp92 on 02/26/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

#import "_AppDelegate.h"
#import <Rudder/Rudder.h>
#import "RudderAmplitudeFactory.h"
#import "RudderBrazeFactory.h"
#import <AdSupport/ASIdentifierManager.h>


static NSString *WRITE_KEY = @"2CpkPQoOX97OkRqVemj5PvUdvkg";
static NSString *DATA_PLANE_URL = @"https://shadowfax-dataplane.dev-rudder.rudderlabs.com";
static NSString *CONTROL_PLANE_URL = @"https://api.dev.rudderlabs.com";

@implementation _AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
    [builder withLoglevel:RSLogLevelVerbose];
    [builder withTrackLifecycleEvens:YES];
    [builder withRecordScreenViews:YES];
    [builder withDataPlaneUrl:DATA_PLANE_URL];
    [builder withControlPlaneUrl:CONTROL_PLANE_URL];
    [builder withFactory:[RudderAmplitudeFactory instance]];
    [builder withFactory:[RudderBrazeFactory instance]];
    [RSClient getInstance:WRITE_KEY config:[builder build]];
    
    [[RSClient sharedInstance] track:@"simple_track_with_props" properties:@{
        @"key_1" : @"value_1",
        @"key_2" : @"value_2"
    }];
    
    [[RSClient sharedInstance] identify:@"testUserId"
                                 traits:@{@"firstname": @"First Name"}
                                options:nil];
    
    [[RSClient sharedInstance] screen:@"ViewController"];
    
    [[RSClient sharedInstance] group:@"sample_group_id"
                              traits:@{@"foo": @"bar",
                                       @"foo1": @"bar1",
                                       @"email": @"ruchira@gmail.com"}
    ];
    
    [[RSClient sharedInstance] alias:@"new_user_id"];
    
    RSOption* option1 = [[RSOption alloc] init];
    [option1 putIntegration:@"Amplitude" isEnabled:YES];
    
    RSOption* option2 = [[RSOption alloc] init];
    [option2 putIntegration:@"Braze" isEnabled:YES];
    
    NSDictionary* props = @{@"data": @YES};
    
    for(int i=0; i<5;i++) {
        NSDictionary* duplicateProps = nil;
        if(i%2 ==0){
            duplicateProps = props;
        }
        [[RSClient sharedInstance] track:[[NSString alloc] initWithFormat:@"Test Event %@: %d", @"Amplitude", i] properties:props options:option1];
        [[RSClient sharedInstance] track:[[NSString alloc] initWithFormat:@"Test Event %@: %d", @"Braze", i] properties:props options:option2];
    }
    
    return YES;
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
