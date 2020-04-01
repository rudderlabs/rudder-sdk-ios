//
//  Constants.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 27/01/20.
//

#import "Constants.h"

@implementation Constants

int const RudderConfigRefreshInterval = 2;
NSString *const RudderBaseUrl = @"https://api.rudderlabs.com";
int const RudderFlushQueueSize = 30;
int const RudderDBCountThreshold = 10000;
int const RudderSleepTimeout = 10;
NSString *const RudderControlPlaneUrl = @"https://api.rudderlabs.com";
bool const RudderTrackLifeCycleEvents = YES;
bool const RudderRecordScreenViews = NO;

@end
