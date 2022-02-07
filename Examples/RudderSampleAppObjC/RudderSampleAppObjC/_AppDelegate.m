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
#import "CustomFactory.h"
#import "RudderAmplitudeFactory.h"


static NSString *WRITE_KEY = @"21zVhiRJL38EAgphqL65VpzyjLB";

@implementation _AppDelegate

NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [RSClient putDeviceToken:@"your_device_token"];
    [RSClient putAnonymousId:@"anonymous_id"];
    
    
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
//    [builder withLoglevel:RSLogLevelVerbose];
    [builder withLoglevel:RSLogLevelNone];
    [builder withTrackLifecycleEvens:NO];
    [builder withRecordScreenViews:NO];
    [builder withEnableBackgroundMode:YES];
    [builder withFactory:[RudderAmplitudeFactory instance]];
    [builder withControlPlaneURL:[NSURL URLWithString:@"https://c9b4-2405-201-8000-6061-1d32-d996-5af-a2b2.ngrok.io"]];
    [builder withDataPlaneURL:[NSURL URLWithString:@"https://b474-2405-201-8000-6061-1d32-d996-5af-a2b2.ngrok.io"]];
    [RSClient getInstance:@"24BjDDJa7PF4GtNCWcHTvbNtYUm" config:[builder build]];
//    [builder withDataPlaneUrl:@"https://rudderstacbumvdrexzj.dataplane.rudderstack.com"];
//    [RSClient getInstance:@"24al1ujFmoFVUvaxd01Br4aEclr" config:[builder build]];
    
//    [[RSClient sharedInstance] track:@"simple_track_with_props" properties:@{
//        @"key_1" : @"value_1",
//        @"key_2" : @"value_2"
//    }];
//    [self makeEvents];
    
//    [self manageThread];
    return YES;
}

+(void) manageThread {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 200; i<500; i++) {
            [_AppDelegate makeEvents:i];
//            NSLog(@"%@",[[NSString alloc] initWithFormat:@"Background Thread- 1 Event - %d", i]);
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 300; i<600; i++) {
            [_AppDelegate makeEvents:i];
//            NSLog(@"%@",[[NSString alloc] initWithFormat:@"Background Thread- 2 Event - %d", i]);
        }
    });
    
    for (int i = 0; i<500; i++) {
        [_AppDelegate makeEvents:i];
//        NSLog(@"%@",[[NSString alloc] initWithFormat:@"Main Thread  Event - %d", i]);
    }
}

+ (void) makeEvents:(int) i {
//    [[RSClient sharedInstance] track: [@"simple_track_with_props " stringByAppendingString:[NSString stringWithFormat:@"%i", i]] properties:@{
//        @"key_1" : @"value_1",
//        @"key_2" : @"value_2"
//    }];
//
//    [[[RSClient sharedInstance] getContext] putAdvertisementId:@"advertisement_Id"];

    RSOption *identifyOptions = [[RSOption alloc] init];
    [identifyOptions putExternalId:@"brazeExternalId" withId:@"some_external_id_1"];
    [[RSClient sharedInstance] identify:@"testUserId"
                                 traits:@{@"firstname": @"First Name"}
                                options:identifyOptions];

//    [[RSClient sharedInstance] screen:@"ViewController"];
//
//    [[RSClient sharedInstance] group:@"sample_group_id"
//                              traits:@{@"foo": @"bar",
//                                       @"foo1": @"bar1",
//                                       @"email": @"ruchira@gmail.com"}
//    ];
    

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

// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // [START_EXCLUDE]
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    // [END_EXCLUDE]
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}
// [END receive_message]

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // [START_EXCLUDE]
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    // [END_EXCLUDE]
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionAlert);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler();
}

// [END ios_10_message_handling]

// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}
// [END refresh_token]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for remote notifications: %@", error);
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"APNs device token retrieved: %@", deviceToken);
    
    // With swizzling disabled you must set the APNs device token here.
    // [FIRMessaging messaging].APNSToken = deviceToken;
}

@end
