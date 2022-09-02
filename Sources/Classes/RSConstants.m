//
//  Constants.m
//  RSSDKCore
//
//  Created by Arnab Pal on 27/01/20.
//

#import "RSConstants.h"

@implementation RSConstants

int const RSConfigRefreshInterval = 2;
NSString *const RSDataPlaneUrl = @"https://hosted.rudderlabs.com/";
int const RSFlushQueueSize = 30;
int const RSDBCountThreshold = 10000;
int const RSSleepTimeout = 10;
int const RSSessionInActivityMinTimeOut = 0;
int const RSSessionInActivityDefaultTimeOut = 300000;
NSString *const RSControlPlaneUrl = @"https://api.rudderlabs.com/";
bool const RSTrackLifeCycleEvents = YES;
bool const RSRecordScreenViews = NO;
bool const RSEnableBackgroundMode = NO;
bool const RSAutomaticSessionTracking = YES;
NSString *const RS_VERSION = @"1.7.0";
NSString* const DISABLE = @"disable";
NSString* const WHITELISTED_EVENTS = @"whitelistedEvents";
NSString* const BLACKLISTED_EVENTS = @"blacklistedEvents";
NSString* const EVENT_FILTERING_OPTION = @"eventFilteringOption";
NSString* const EVENT_NAME = @"eventName";
@end
