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


static NSString *WRITE_KEY = @"1xXCubSHWXbpBI2h6EpCjKOsxmQ";
static NSString *DATA_PLANE_URL = @"https://rudderstacgwyx.dataplane.rudderstack.com";
static NSString *CONTROL_PLANE_URL = @"https://api.dev.rudderlabs.com";

@implementation _AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
    [builder withLoglevel:RSLogLevelVerbose];
    [builder withTrackLifecycleEvens:YES];
    [builder withRecordScreenViews:YES];
    [builder withDataPlaneUrl:DATA_PLANE_URL];
//    [builder withControlPlaneUrl:CONTROL_PLANE_URL];
    [builder withDataResidencyServer:US];
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

@end
