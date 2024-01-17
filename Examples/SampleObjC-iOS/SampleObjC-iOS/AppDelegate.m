//
//  AppDelegate.m
//  SampleiOSObjC
//
//  Created by Pallab Maiti on 21/03/22.
//

#import "AppDelegate.h"
#import "SampleObjC_iOS-Swift.h"
#import <AdSupport/ASIdentifierManager.h>

@import Rudder;

static NSString *DATA_PLANE_URL = @"https://rudderstacz.dataplane.rudderstack.com";
static NSString *WRITE_KEY = @"1wvsoF3Kx2SczQNlx1dvcqW9ODW";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    Config *config = [[Config alloc] initWithWriteKey:WRITE_KEY];
    [config dataPlaneURL:DATA_PLANE_URL];
    [config loglevel:RSLogLevelDebug];
    [config trackLifecycleEvents:YES];
    [config recordScreenViews:YES];
    RSClient *client = [RSClient sharedInstance];
    [client configureWith:config];
    [client addDestination:[[CustomDestination alloc] init]];
    
//    [client identify:@"user_id" traits:@{@"email": @"abc@def.com"}];
//    [client track:@"track 1" properties:@{@"key_1": @"value_1", @"key_2": @"value_2"}];
//    [client screen:@"ViewController" properties:@{@"key_1": @"value_1", @"key_2": @"value_2"}];
//    [client group:@"sample_group_id" traits:@{@"key_1": @"value_1", @"key_2": @"value_2"}];
//    [client alias:@"user_id"];
    
    /*[client reset];
    [client setDeviceToken:@"example_device_token"];
    [client setAdvertisingId:[self getIDFA]];
    [client setAppTrackingConsent:RSAppTrackingConsentAuthorize];
    [client setAnonymousId:@"example_anonymous_id"];
    
    Option *defaultOption = [[Option alloc] init];
    [defaultOption putIntegration:@"Amplitude" isEnabled:YES];
    [client setOption:defaultOption];
    
    Option *eventOption = [[Option alloc] init];
    [eventOption putIntegration:@"Amplitude" isEnabled:YES];
    [eventOption putExternalId:@"brazeExternalId" withId:@"some_external_id_1"];
    [client identify:@"user_id" traits:@{@"email": @"abc@def.com"} option:eventOption];
    
    NSDictionary *traits = [client traits];*/
    
    return YES;
}

- (NSString*)getIDFA {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
