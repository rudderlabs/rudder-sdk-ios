//
//  RSApplicationLifeCycleManager.m
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSApplicationLifeCycleManager.h"
#import <Rudder/UIViewController+RSScreen.h>
#import <Rudder/WKInterfaceController+RSScreen.h>

@implementation RSApplicationLifeCycleManager


- (instancetype)initWithConfig:(RSConfig*) config andPreferenceManager:(RSPreferenceManager*) preferenceManager andBackGroundModeManager:(RSBackGroundModeManager *) backGroundModeManager {
    self = [super init];
    if(self){
        self->config = config;
        self->preferenceManager = preferenceManager;
        self->firstForeGround = YES;
        self->backGroundModeManager = backGroundModeManager;
    }
    return self;
}

#if !TARGET_OS_WATCH
- (void) trackApplicationLifeCycle {
    [RSLogger logVerbose:@"RSApplicationLifeCycleManager: trackApplicationLifeCycle: Registering for Application Life Cycle Notifications"];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    for (NSString *name in @[ UIApplicationDidEnterBackgroundNotification,
                              UIApplicationDidFinishLaunchingNotification,
                              UIApplicationWillEnterForegroundNotification,
                              UIApplicationWillTerminateNotification,
                              UIApplicationWillResignActiveNotification,
                              UIApplicationDidBecomeActiveNotification ]) {
        [nc addObserver:self selector:@selector(handleAppStateNotification:) name:name object:UIApplication.sharedApplication];
    }
}

- (void) handleAppStateNotification: (NSNotification*) notification {
    if ([notification.name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
        [self applicationDidFinishLaunchingWithOptions:notification.userInfo];
    } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self applicationWillEnterForeground];
    } else if ([notification.name isEqualToString: UIApplicationDidEnterBackgroundNotification]) {
        [self applicationDidEnterBackground];
    }
}

#else
- (void) trackApplicationLifeCycle {
    [RSLogger logVerbose:@"RSApplicationLifeCycleManager: trackApplicationLifeCycle: Registering for Application Life Cycle Notifications"];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    for (NSString *name in @[ WKApplicationDidEnterBackgroundNotification,
                              WKApplicationDidFinishLaunchingNotification,
                              WKApplicationWillEnterForegroundNotification,
                              WKApplicationWillResignActiveNotification,
                              WKApplicationDidBecomeActiveNotification ]) {
        [nc addObserver:self selector:@selector(handleAppStateNotification:) name:name object:nil];
    }
}

- (void) handleAppStateNotification: (NSNotification*) notification {
    if ([notification.name isEqualToString:WKApplicationDidFinishLaunchingNotification]) {
        [self applicationDidFinishLaunchingWithOptions:notification.userInfo];
    } else if ([notification.name isEqualToString: WKApplicationDidBecomeActiveNotification]) {
        [self applicationWillEnterForeground];
    } else if ([notification.name isEqualToString: WKApplicationWillResignActiveNotification]) {
        [self applicationDidEnterBackground];
    }
}
#endif

- (void) applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (!self->config.trackLifecycleEvents) {
        return;
    }
    NSString *previousVersion = [preferenceManager getVersionNumber];
       NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
       
       NSString* previousBuildNumber = [preferenceManager getBuildNumber];
       NSString *currentBuildNumber = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
       
       if (!previousVersion) {
           [RSLogger logVerbose:@"RSApplicationLifeCycleManager: applicationDidFinishLaunchingWithOptions: Tracking Application Installed"];
           [[RSClient sharedInstance] track:@"Application Installed" properties:@{
               @"version": currentVersion,
               @"build": currentBuildNumber
           }];
           [preferenceManager saveVersionNumber:currentVersion];
           [preferenceManager saveBuildNumber:currentBuildNumber];
       } else if (![previousVersion isEqualToString:currentVersion]) {
           [RSLogger logVerbose:@"RSApplicationLifeCycleManager: applicationDidFinishLaunchingWithOptions: Tracking Application Updated"];
           [[RSClient sharedInstance] track:@"Application Updated" properties:@{
               @"previous_version" : previousVersion ?: @"",
               @"version": currentVersion,
               @"previous_build": previousBuildNumber ?: @"",
               @"build": currentBuildNumber
           }];
           [preferenceManager saveVersionNumber:currentVersion];
           [preferenceManager saveBuildNumber:currentBuildNumber];
       }
    [self sendApplicationOpenedOnLaunch:launchOptions withVersion:currentVersion];
}

- (void) applicationWillEnterForeground {
#if TARGET_OS_WATCH
    if(self->firstForeGround) {
        self->firstForeGround = NO;
        return;
    }
#endif
    [self->backGroundModeManager registerForBackGroundMode];
    if (!self->config.trackLifecycleEvents) {
        return;
    }
    [self sendApplicationOpenedWithProperties:@{@"from_background" : @YES}];
}

- (void) sendApplicationOpenedOnLaunch:(NSDictionary *)launchOptions withVersion:(NSString *) version {
    NSMutableDictionary *applicationOpenedProperties = [[NSMutableDictionary alloc] init];
    [applicationOpenedProperties setObject:@NO forKey:@"from_background"];
    if (version != nil) {
        [applicationOpenedProperties setObject:version forKey:@"version"];
    }
#if !TARGET_OS_WATCH
    NSString *referring_application = [[NSString alloc] initWithFormat:@"%@", launchOptions[UIApplicationLaunchOptionsSourceApplicationKey] ?: @""];
    if ([referring_application length]) {
        [applicationOpenedProperties setObject:referring_application forKey:@"referring_application"];
    }
    NSString *url = [[NSString alloc] initWithFormat:@"%@", launchOptions[UIApplicationLaunchOptionsURLKey] ?: @""];
    if ([url length]) {
        [applicationOpenedProperties setObject:url forKey:@"url"];
    }
#endif
    [self sendApplicationOpenedWithProperties:applicationOpenedProperties];
}

- (void) sendApplicationOpenedWithProperties:(NSDictionary *) properties {
    [RSLogger logVerbose:@"RSApplicationLifeCycleManager: sendApplicationOpenedWithProperties: Tracking Application Opened"];
    [[RSClient sharedInstance] track:@"Application Opened" properties:properties];
}

- (void) applicationDidEnterBackground {
    if (!self->config.trackLifecycleEvents) {
        return;
    }
    [RSLogger logVerbose:@"RSApplicationLifeCycleManager: applicationDidEnterBackground: Tracking Application Backgrounded"];
    [[RSClient sharedInstance] track:@"Application Backgrounded"];
}

- (void) prepareScreenRecorder {
#if TARGET_OS_WATCH
    [WKInterfaceController rudder_swizzleView];
#else
    [UIViewController rudder_swizzleView];
#endif
}

@end
