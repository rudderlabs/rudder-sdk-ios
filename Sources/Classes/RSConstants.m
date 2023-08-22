//
//  Constants.m
//  RSSDKCore
//
//  Created by Arnab Pal on 27/01/20.
//

#import "RSConstants.h"
#import "RSVersion.h"

@implementation RSConstants

int const RSConfigRefreshInterval = 2;
NSString *const RSDataPlaneUrl = @"https://hosted.rudderlabs.com/";
int const RSFlushQueueSize = 30;
int const RSDBCountThreshold = 10000;
int const RSSleepTimeout = 10;
long const RSSessionInActivityMinTimeOut = 0;
long const RSSessionInActivityDefaultTimeOut = 300000;
NSString *const RSControlPlaneUrl = @"https://api.rudderlabs.com/";
bool const RSTrackLifeCycleEvents = YES;
bool const RSRecordScreenViews = NO;
bool const RSEnableBackgroundMode = NO;
bool const RSAutomaticSessionTracking = YES;
bool const RSCollectDeviceId = YES;
bool const RSGzipStatus = YES;
NSString *const RS_VERSION = SDK_VERSION;
NSString* const DISABLE = @"disable";
NSString* const WHITELISTED_EVENTS = @"whitelistedEvents";
NSString* const BLACKLISTED_EVENTS = @"blacklistedEvents";
NSString* const EVENT_FILTERING_OPTION = @"eventFilteringOption";
NSString* const EVENT_NAME = @"eventName";
NSString *const WRITE_KEY_ERROR = @"Invalid writeKey: Provided writeKey is empty";
NSString *const DATA_PLANE_URL_ERROR = @"Invalid dataPlaneUrl: The dataPlaneUrl is not provided or given dataPlaneUrl is not valid\n**Note: dataPlaneUrl or dataResidencyServer(for Enterprise Users only) is mandatory from version 1.11.0**";
NSString *const DATA_PLANE_URL_FLUSH_ERROR = @"Invalid dataPlaneUrl: The dataPlaneUrl is not provided or given dataPlaneUrl is not valid. Ignoring flush call. \n**Note: dataPlaneUrl or dataResidencyServer(for Enterprise Users only) is mandatory from version 1.11.0**";

int const RSATTNotDetermined = 0;
int const RSATTRestricted = 1;
int const RSATTDenied = 2;
int const RSATTAuthorize = 3;

@end
