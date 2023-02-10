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


static NSString *WRITE_KEY = @"21zVhiRJL38EAgphqL65VpzyjLB";

@implementation _AppDelegate

NSString *const kGCMMessageIDKey = @"gcm.message_id";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [RSClient putDeviceToken:@"your_device_token"];
    [RSClient putAnonymousId:@"anonymous_id"];
    
    
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
    [builder withLoglevel:RSLogLevelVerbose];
    [builder withTrackLifecycleEvens:YES];
    [builder withRecordScreenViews:YES];
    [builder withEnableBackgroundMode:YES];
    [builder withDataPlaneUrl:@"http://localhost:8080"];
    [builder withDataResidencyServer:US];
    [builder withCustomFactory:[CustomFactory instance]];
    [RSClient getInstance:@"1wvsoF3Kx2SczQNlx1dvcqW9ODW" config:[builder build]];
    
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
    return YES;
}

- (NSString*) getIDFA {
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

- (NSString*) getDeviceToken {
    return @"example_device_token";
}
@end
