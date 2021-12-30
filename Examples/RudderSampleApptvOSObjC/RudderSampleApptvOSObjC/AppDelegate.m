//
//  AppDelegate.m
//  Sample-tvOS
//
//  Created by Desu Sai Venkat on 18/10/21.
//

#import "AppDelegate.h"
#import "CustomFactory.h"
#import <Rudder/Rudder.h>

@interface AppDelegate ()

@end

static NSString *WRITE_KEY = @"21zVhiRJL38EAgphqL65VpzyjLB";


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
    [builder withLoglevel:RSLogLevelDebug];
    [builder withTrackLifecycleEvens:YES];
    [builder withRecordScreenViews:YES];
    [builder withCustomFactory:[CustomFactory instance]];
    
    [RSClient putAnonymousId:@"ANONYMOUS_ID"];
    // creating the client object by passing the options object
    [RSClient getInstance:WRITE_KEY config:[builder build]];
    

    return YES;
}

+ (void) identify {
    RSOption *identifyOptions = [[RSOption alloc] init];
    [identifyOptions putExternalId:@"brazeExternalId1" withId:@"some_external_id_1"];
    
    [[RSClient sharedInstance] identify:@"test_user_id1"
                                 traits:@{@"foo1": @"bar1",
                                          @"email": @"test1@gmail.com",
                                          @"key_1" : @"value_1",
                                 } options: identifyOptions
    ];
}

+ (void) track {
    [[RSClient sharedInstance] track:@"simple_track_with_props" properties:@{
        @"key_1" : @"value_1",
        @"key_2" : @"value_2"
    }];
    
}

+ (void) reset {
    [[RSClient sharedInstance] reset];
    
}

+ (void) screen {
    [[RSClient sharedInstance] screen:@"ViewController"];
}

+ (void) optIn {
    [[RSClient sharedInstance]optOut:NO];
}

+ (void) optOut {
    [[RSClient sharedInstance]optOut:YES];
    
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
