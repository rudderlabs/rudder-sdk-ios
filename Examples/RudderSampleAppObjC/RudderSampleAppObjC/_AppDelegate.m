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
#import "RudderSampleAppObjC-Swift.h"


static int userCount = 1;
static int eventCount = 1;
static int groupCount = 1;
static int screenCount = 1;



@implementation _AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"RudderConfig" ofType:@"plist"];
    if (path != nil) {
        NSURL *url = [NSURL fileURLWithPath:path];
        RudderConfig *rudderConfig = [RudderConfig createFrom:url];
        if (rudderConfig != nil) {
            RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
            [builder withLoglevel:RSLogLevelVerbose];
            [builder withTrackLifecycleEvens:YES];
            [builder withCollectDeviceId:NO];
            [builder withRecordScreenViews:YES];
            [builder withDataPlaneUrl:@"https://rudderstachvf.dataplane.rudderstack.com"];
            [RSClient getInstance:@"1pTxG1Tqxr7FCrqIy7j0p28AENV" config:[builder build]];
        }
    }
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

@end
