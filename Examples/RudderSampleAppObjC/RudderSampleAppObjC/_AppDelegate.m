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


static int userCount = 1;
static int eventCount = 1;
static int groupCount = 1;
static int screenCount = 1;



@implementation _AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    /// Create a `configuration.json` file on root directory. The JSON should be look like:
    /// {
    ///    "writeKey": "WRITE_KEY_VALUE",
    ///    "dataPlaneUrl": "DATA_PLANE_URL_VALUE",
    ///    "controlPlaneUrl": "CONTROL_PLANE_URL_VALUE"
    /// }
    
    NSDictionary *dict = [self JSONFromFile];
    NSString* dataPlaneUrl = dict[@"dataPlaneUrl"];
    NSString* writeKey = dict[@"writeKey"];
    NSString* controlPlaneUrl = dict[@"controlPlaneUrl"];
    
    [RSClient putAuthToken:@"testAuthToken"];
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
    [builder withLoglevel:RSLogLevelVerbose];
    [builder withTrackLifecycleEvens:YES];
    [builder withRecordScreenViews:YES];
    [builder withDataPlaneUrl:dataPlaneUrl];
    [builder withControlPlaneUrl:controlPlaneUrl];
    [builder withFactory:[RudderAmplitudeFactory instance]];
    [builder withFactory:[RudderBrazeFactory instance]];
    [RSClient getInstance:writeKey config:[builder build]];
    
    return YES;
}

+ (void) sendIdentify {
    NSString* userId = [[NSString alloc] initWithFormat:@"User %d",userCount];
    NSString* userEmail = [[NSString alloc] initWithFormat:@"User%d@gmail.com",userCount];
    NSString* userName = [[NSString alloc] initWithFormat:@"Mr. User %d",userCount];
    [[RSClient sharedInstance] identify:userId traits:@{
        @"email": userEmail,
        @"name": userName
    }];
    userCount = userCount+1;
}

+ (void) sendTrack {
    NSString* eventName = [[NSString alloc] initWithFormat:@"Test Event %d",eventCount];
    NSString* propKey = [[NSString alloc] initWithFormat:@"Test Event Key %d",eventCount];
    NSString* propValue = [[NSString alloc] initWithFormat:@"Test Event Value %d",eventCount];
    [[RSClient sharedInstance] track:eventName properties: @{
        propKey : propValue
    }];
    eventCount = eventCount + 1;
}

+ (void) sendScreen {
    NSString* screenName = [[NSString alloc] initWithFormat:@"Test Screen %d",eventCount];
    NSString* propKey = [[NSString alloc] initWithFormat:@"Test Screen Key %d",eventCount];
    NSString* propValue = [[NSString alloc] initWithFormat:@"Test Screen Value %d",eventCount];
    [[RSClient sharedInstance] screen:screenName properties: @{
        propKey : propValue
    }];
    screenCount = screenCount+1;
}

+ (void) sendGroup {
    NSString* groupId = [[NSString alloc] initWithFormat:@"group %d",groupCount];
    [[RSClient sharedInstance] group:groupId];
    groupCount = groupCount+1;
}

+ (void) sendAlias {
    NSString* newUserId = [[NSString alloc] initWithFormat:@"New User %d",userCount];
    [[RSClient sharedInstance] alias:newUserId];
}

+ (void) sendReset {
    [[RSClient sharedInstance] reset];
}

- (id)JSONFromFile
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"configuration" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
}
@end
