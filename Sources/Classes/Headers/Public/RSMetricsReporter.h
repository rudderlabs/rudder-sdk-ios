//
//  RSMetricsReporter.h
//  Rudder
//
//  Created by Pallab Maiti on 20/07/23.
//

#import <Foundation/Foundation.h>
#import "RSConfig.h"
#import "RSEnums.h"
#import "RSServerConfigSource.h"
#import "RSPreferenceManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface RSMetricsReporter : NSObject

+ (instancetype)initiateWithWriteKey:(NSString *)writeKey preferenceManager:(RSPreferenceManager *)preferenceManager andConfig:(RSConfig *)config;
+ (void)report:(NSString *)metricName forMetricType:(METRIC_TYPE)metricType withProperties:(NSDictionary * _Nullable )properties andValue:(float)value;
+ (void)setErrorsCollectionEnabled:(BOOL)status;
+ (void)setMetricsCollectionEnabled:(BOOL)status;

extern NSString *const SDKMETRICS_SUBMITTED_EVENTS;
extern NSString *const SDKMETRICS_EVENTS_DISCARDED;
extern NSString *const SDKMETRICS_DM_EVENT;
extern NSString *const SDKMETRICS_CM_EVENT;
extern NSString *const SDKMETRICS_DM_DISCARD;
extern NSString *const SDKMETRICS_SC_ATTEMPT_SUCCESS;
extern NSString *const SDKMETRICS_SC_ATTEMPT_RETRY;
extern NSString *const SDKMETRICS_SC_ATTEMPT_ABORT;
extern NSString *const SDKMETRICS_CM_ATTEMPT_SUCCESS;
extern NSString *const SDKMETRICS_CM_ATTEMPT_RETRY;
extern NSString *const SDKMETRICS_CM_ATTEMPT_ABORT;

extern NSString *const SDKMETRICS_TYPE;
extern NSString *const SDKMETRICS_OPT_OUT;
extern NSString *const SDKMETRICS_SDK_DISABLED;
extern NSString *const SDKMETRICS_MSG_SIZE_INVALID;
extern NSString *const SDKMETRICS_BATCH_SIZE_INVALID;
extern NSString *const SDKMETRICS_MSG_FILTERED;
extern NSString *const SDKMETRICS_OUT_OF_MEMORY;
extern NSString *const SDKMETRICS_QUEUES;
extern NSString *const SDKMETRICS_MESSAGES;
extern NSString *const SDKMETRICS_DM_DISSENTED;
extern NSString *const SDKMETRICS_DM_DISABLED;
extern NSString *const SDKMETRICS_CONTROL_PLANE_URL_INVALID;
extern NSString *const SDKMETRICS_DATA_PLANE_URL_INVALID;
extern NSString *const SDKMETRICS_SOURCE_DISABLED;
extern NSString *const SDKMETRICS_WRITEKEY_INVALID;
extern NSString *const SDKMETRICS_INTEGRATION;
extern NSString *const SDKMETRICS_REQUEST_TIMEOUT;

@end

NS_ASSUME_NONNULL_END
