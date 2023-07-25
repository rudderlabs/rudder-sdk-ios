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


NS_ASSUME_NONNULL_BEGIN

@interface RSMetricsReporter : NSObject

+ (instancetype)initiateWithWriteKey:(NSString *)writeKey andConfig:(RSConfig *)config;
+ (void)report:(NSString *)metricName forMetricType:(METRIC_TYPE)metricType withProperties:(NSDictionary * _Nullable )properties andValue:(float)value;
+ (void)setErrorsCollectionEnabled:(BOOL)status;
+ (void)setMetricsCollectionEnabled:(BOOL)status;

extern NSString *const SUBMITTED_EVENTS;
extern NSString *const EVENTS_DISCARDED;
extern NSString *const DM_EVENT;
extern NSString *const CM_EVENT;
extern NSString *const DM_DISCARD;
extern NSString *const SC_ATTEMPT_SUCCESS;
extern NSString *const SC_ATTEMPT_RETRY;
extern NSString *const SC_ATTEMPT_ABORT;
extern NSString *const CM_ATTEMPT_SUCCESS;
extern NSString *const CM_ATTEMPT_RETRY;
extern NSString *const CM_ATTEMPT_ABORT;

extern NSString *const TYPE;
extern NSString *const OPT_OUT;
extern NSString *const SDK_DISABLED;
extern NSString *const MSG_SIZE_INVALID;
extern NSString *const MSG_FILTERED;
extern NSString *const OUT_OF_MEMORY;
extern NSString *const QUEUES;
extern NSString *const MESSAGES;
extern NSString *const DM_DISSENTED;
extern NSString *const DM_DISABLED;
extern NSString *const CONTROL_PLANE_URL_INVALID;
extern NSString *const DATA_PLANE_URL_INVALID;
extern NSString *const SOURCE_DISABLED;
extern NSString *const WRITEKEY_INVALID;
extern NSString *const INTEGRATION;

@end

NS_ASSUME_NONNULL_END
