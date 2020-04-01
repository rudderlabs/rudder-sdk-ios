//
//  Constants.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 27/01/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Constants : NSObject

// how often config should be fetched from the server (in hours) (2 hrs by default)
extern int const RudderConfigRefreshInterval;
// default base url or rudder-backend-server
extern NSString *const RudderBaseUrl;
// default flush queue size for the events to be flushed to server
extern int const RudderFlushQueueSize;
// default threshold of number of events to be persisted in sqlite db
extern int const RudderDBCountThreshold;
// default timeout for event flush
// if events are registered and flushQueueSize is not reached
// events will be flushed to server after sleepTimeOut seconds
extern int const RudderSleepTimeout;
// config-plane url to get the config for the writeKey
extern NSString *const RudderControlPlaneUrl;
// whether we should trackLifecycle events
extern bool const RudderTrackLifeCycleEvents;
// whether we should record screen views automatically
extern bool const RudderRecordScreenViews;
@end

NS_ASSUME_NONNULL_END
