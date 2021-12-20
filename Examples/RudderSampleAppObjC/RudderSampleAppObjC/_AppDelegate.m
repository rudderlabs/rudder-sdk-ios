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


static NSString *DATA_PLANE_URL = @"https://a477-61-95-158-116.ngrok.io";
static NSString *WRITE_KEY = @"1n0JdVPZTRUIkLXYccrWzZwdGSx";

@implementation _AppDelegate

NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [RSClient putAnonymousId:@"AnonymousId1"];
    [RSClient putDeviceToken:@"DeviceToken1"];
    [[[RSClient sharedInstance] getContext] putAdvertisementId:@"AdvertisementId1"];

    
    // Override point for customization after application launch.
    RSOption *defaultOption = [[RSOption alloc]init];
    // adding an integration into integrations object directly by specifying its name
    [defaultOption putIntegration:@"Amplitude" isEnabled:YES];
    [defaultOption putIntegration:@"MoEngage" isEnabled:YES];
    [defaultOption putIntegration:@"All" isEnabled:NO];
    // adding an integration into integrations object using its Factory object
    // [defaultOption putIntegrationWithFactory:[RudderMoengageFactory instance] isEnabled:NO];
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
    [builder withDataPlaneURL:[[NSURL alloc] initWithString:DATA_PLANE_URL]];
    [builder withLoglevel:RSLogLevelDebug];
    [builder withTrackLifecycleEvens:YES];
    [builder withRecordScreenViews:YES];
    // creating Custom factory
    [builder withCustomFactory:[CustomFactory instance]];
    // creating the client object by passing the options object
    [RSClient getInstance:WRITE_KEY config:[builder build] options:defaultOption];
//    [[[RSClient sharedInstance] getContext] putAdvertisementId:[self getIDFA]];
    [[[RSClient sharedInstance] getContext] putAppTrackingConsent:RSATTAuthorize];
    
    
    RSOption *option = [[RSOption alloc]init];
    [option putIntegration:@"Amplitude" isEnabled:YES];
    [option putIntegration:@"MixPanel" isEnabled:NO];
    [option putCustomContext: @{
        @"language": @"objective-c",
        @"version": @"1.0.0"
    } withKey: @"customContext"];
    [[RSClient sharedInstance] track:@"simple_track_event1"];
    
    [[RSClient sharedInstance] optOut:YES];
    [RSClient putAnonymousId:@"AnonymousId2"];
    [RSClient putDeviceToken:@"DeviceToken2"];
    [[[RSClient sharedInstance] getContext] putAdvertisementId:@"AdvertisementId2"];
    [[RSClient sharedInstance] track:@"simple_track_event2"];
    [[RSClient sharedInstance] track:@"simple_track_event3"];
    [[RSClient sharedInstance] track:@"simple_track_event4"];

    [[RSClient sharedInstance] optOut:NO];
    [RSClient setAnonymousId:@"AnonymousId3"];
    [RSClient putDeviceToken:@"DeviceToken3"];
    [[[RSClient sharedInstance] getContext] putAdvertisementId:@"AdvertisementId3"];
    [[RSClient sharedInstance] track:@"simple_track_event4"];
    [[RSClient sharedInstance] track:@"simple_track_event5"];
    [[RSClient sharedInstance] track:@"simple_track_event6"];

    
//    [RSClient putDeviceToken:@"DEVTOKEN2"];
//    [[RSClient sharedInstance] track:@"simple_track_with_props" properties:@{
//        @"key_1" : @"value_1",
//        @"key_2" : @"value_2"
//    } options:option];
//
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
    UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
    [[UNUserNotificationCenter currentNotificationCenter]
     requestAuthorizationWithOptions:authOptions
     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        // ...
    }];
    
    [application registerForRemoteNotifications];
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
