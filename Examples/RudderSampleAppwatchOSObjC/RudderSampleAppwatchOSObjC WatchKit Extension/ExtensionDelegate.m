//
//  ExtensionDelegate.m
//  RudderSampleAppwatchOSObjC WatchKit Extension
//
//  Created by Desu Sai Venkat on 01/12/21.
//

#import "ExtensionDelegate.h"
#import <Rudder/Rudder.h>
#import "RudderSampleAppwatchOSObjC_WatchKit_Extension-Swift.h"

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    // Perform any final initialization of your application.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"RudderConfig" ofType:@"plist"];
    if (path != nil) {
        NSURL *url = [NSURL fileURLWithPath:path];
        RudderConfig *rudderConfig = [RudderConfig createFrom:url];
        if (rudderConfig != nil) {
            [RSClient putDeviceToken:@"your_device_token"];
            [RSClient putAnonymousId:@"anonymous_id"];
            
            
            RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
            [builder withLoglevel:RSLogLevelVerbose];
            [builder withTrackLifecycleEvens:YES];
            //        [builder withEnableBackgroundMode:YES];
            [builder withRecordScreenViews:YES];
            [builder withDataPlaneUrl:rudderConfig.PROD_DATA_PLANE_URL];
            [RSClient getInstance:rudderConfig.WRITE_KEY config:[builder build]];
            
            [[RSClient sharedInstance] track:@"simple_track_with_props" properties:@{
                @"key_1" : @"value_1",
                @"key_2" : @"value_2"
            }];
            
            [[[RSClient sharedInstance] getContext] putAdvertisementId:@"advertisement_Id"];
            
            RSOption *identifyOptions = [[RSOption alloc] init];
            [identifyOptions putExternalId:@"brazeExternalId" withId:@"some_external_id_1"];
            [[RSClient sharedInstance] identify:@"testUserId"
                                         traits:@{@"firstname": @"First Name"}
                                        options:identifyOptions];
            
            [[RSClient sharedInstance] screen:@"ViewController"];
            
            [[RSClient sharedInstance] group:@"sample_group_id"
                                      traits:@{@"foo": @"bar",
                                               @"foo1": @"bar1",
                                               @"email": @"ruchira@gmail.com"}
            ];
            
            [[RSClient sharedInstance] alias:@"new_user_id"];
        }
    }
}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

- (void)handleBackgroundTasks:(NSSet<WKRefreshBackgroundTask *> *)backgroundTasks {
    // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
    for (WKRefreshBackgroundTask * task in backgroundTasks) {
        // Check the Class of each task to decide how to process it
        if ([task isKindOfClass:[WKApplicationRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKApplicationRefreshBackgroundTask *backgroundTask = (WKApplicationRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKSnapshotRefreshBackgroundTask class]]) {
            // Snapshot tasks have a unique completion call, make sure to set your expiration date
            WKSnapshotRefreshBackgroundTask *snapshotTask = (WKSnapshotRefreshBackgroundTask*)task;
            [snapshotTask setTaskCompletedWithDefaultStateRestored:YES estimatedSnapshotExpiration:[NSDate distantFuture] userInfo:nil];
        } else if ([task isKindOfClass:[WKWatchConnectivityRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKWatchConnectivityRefreshBackgroundTask *backgroundTask = (WKWatchConnectivityRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKURLSessionRefreshBackgroundTask class]]) {
            // Be sure to complete the background task once you’re done.
            WKURLSessionRefreshBackgroundTask *backgroundTask = (WKURLSessionRefreshBackgroundTask*)task;
            [backgroundTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKRelevantShortcutRefreshBackgroundTask class]]) {
            // Be sure to complete the relevant-shortcut task once you’re done.
            WKRelevantShortcutRefreshBackgroundTask *relevantShortcutTask = (WKRelevantShortcutRefreshBackgroundTask*)task;
            [relevantShortcutTask setTaskCompletedWithSnapshot:NO];
        } else if ([task isKindOfClass:[WKIntentDidRunRefreshBackgroundTask class]]) {
            // Be sure to complete the intent-did-run task once you’re done.
            WKIntentDidRunRefreshBackgroundTask *intentDidRunTask = (WKIntentDidRunRefreshBackgroundTask*)task;
            [intentDidRunTask setTaskCompletedWithSnapshot:NO];
        } else {
            // make sure to complete unhandled task types
            [task setTaskCompletedWithSnapshot:NO];
        }
    }
}

@end
