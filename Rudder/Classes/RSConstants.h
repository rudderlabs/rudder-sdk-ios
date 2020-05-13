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
// config-plane url to get the config for the writeKey
extern NSString *const RSControlPlaneUrl;
// whether we should trackLifecycle events
extern bool const RSTrackLifeCycleEvents;
// whether we should record screen views automatically
extern bool const RSRecordScreenViews;
// SDK Version
extern NSString *const RS_VERSION;

@end

NS_ASSUME_NONNULL_END
