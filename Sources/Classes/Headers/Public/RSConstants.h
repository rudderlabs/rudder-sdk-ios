//
//  Constants.h
//  RSSDKCore
//
//  Created by Arnab Pal on 27/01/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSConstants : NSObject

// how often config should be fetched from the server (in hours) (2 hrs by default)
extern int const RSConfigRefreshInterval;
// default base url or rudder-backend-server
extern NSString *const RSDataPlaneUrl;
// default flush queue size for the events to be flushed to server
extern int const RSFlushQueueSize;
// default threshold of number of events to be persisted in sqlite db
extern int const RSDBCountThreshold;
// default timeout for event flush
// if events are registered and flushQueueSize is not reached
// events will be flushed to server after sleepTimeOut seconds
extern int const RSSleepTimeout;
// Minimum value for the In Activity timeout after which the current session expires.
extern long const RSSessionInActivityMinTimeOut;
// Default value for the In Activity timeout after which the current session expires.
extern long const RSSessionInActivityDefaultTimeOut;
// config-plane url to get the config for the writeKey
extern NSString *const RSControlPlaneUrl;
// whether we should trackLifecycle events
extern bool const RSTrackLifeCycleEvents;
// whether we should record screen views automatically
extern bool const RSRecordScreenViews;
// whether we should add support for background run time
extern bool const RSEnableBackgroundMode;
// default for automatic session tracking
extern bool const RSAutomaticSessionTracking;
// default for collection of Device Id i.e IDFV by the SDK
extern bool const RSCollectDeviceId;
// default for gzip request payload
extern bool const RSGzipStatus;
// SDK Version
extern NSString *const RS_VERSION;
// constant used to check if event filtering is disabled
extern NSString* const DISABLE;
// constant used to check if event filtering use white listed events
extern NSString* const WHITELISTED_EVENTS;
// constant used to check if event filtering use black listed events
extern NSString* const BLACKLISTED_EVENTS;
// constant used to check the event filtering option set for a destination in the destination config
extern NSString* const EVENT_FILTERING_OPTION;
// constant used in retrieving event name form the white/black list events from the destination config
extern NSString* const EVENT_NAME;

// Error messages
extern NSString *const WRITE_KEY_ERROR;
extern NSString *const DATA_PLANE_URL_ERROR;
extern NSString *const DATA_PLANE_URL_FLUSH_ERROR;

extern int const RSATTNotDetermined;
extern int const RSATTRestricted;
extern int const RSATTDenied;
extern int const RSATTAuthorize;

@end

NS_ASSUME_NONNULL_END
