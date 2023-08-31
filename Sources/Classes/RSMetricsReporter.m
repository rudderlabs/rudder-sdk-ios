//
//  RSMetricsReporter.m
//  Rudder
//
//  Created by Pallab Maiti on 20/07/23.
//

#import "RSMetricsReporter.h"
#import "RSConstants.h"
#import "RSLogger.h"

@import MetricsReporter;

@implementation RSMetricsReporter

static RSMetricsReporter* _instance;
static dispatch_queue_t queue;
RSMetricsClient * _Nullable _metricsClient;

+ (instancetype)initiateWithWriteKey:(NSString *)writeKey preferenceManager:(RSPreferenceManager *)preferenceManager andConfig:(RSConfig *)config {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] initWithWriteKey:writeKey preferenceManager:preferenceManager andConfig:config];
        });
    }
    return _instance;
}

- (instancetype)initWithWriteKey:(NSString *)writeKey preferenceManager:(RSPreferenceManager *)preferenceManager andConfig:(RSConfig *)config {
    self = [super init];
    if (self) {
        RSMetricConfiguration *configuration = [[RSMetricConfiguration alloc] initWithLogLevel:config.logLevel writeKey:writeKey sdkVersion:RS_VERSION];
        [configuration dbCountThreshold:config.dbCountThreshold];
        _metricsClient = [[RSMetricsClient alloc] initWithConfiguration:configuration];
        _metricsClient.isMetricsCollectionEnabled = preferenceManager.isMetricsCollectionEnabled;
        _metricsClient.isErrorsCollectionEnabled = preferenceManager.isErrorsCollectionEnabled;
    }
    return self;
}

+ (void)setErrorsCollectionEnabled:(BOOL)status {
    if (_metricsClient != nil)
        _metricsClient.isErrorsCollectionEnabled = status;
}

+ (void)setMetricsCollectionEnabled:(BOOL)status {
    if (_metricsClient != nil)
        _metricsClient.isMetricsCollectionEnabled = status;
}

+ (void)report:(NSString *)metricName forMetricType:(METRIC_TYPE)metricType withProperties:(NSDictionary * _Nullable )properties andValue:(float)value {
    @try {
        switch (metricType) {
            case COUNT: {
                RSCount *count = [[RSCount alloc] initWithName:metricName labels:properties value:(int)value];
                if (_metricsClient != nil)
                    [_metricsClient process:count];
            }
                break;
            case GAUGE: {
                RSGauge *gauge = [[RSGauge alloc] initWithName:metricName labels:properties value:value];
                if (_metricsClient != nil)
                    [_metricsClient process:gauge];
            }
                break;
            default:
                break;
        }
    } @catch (NSException *exception) {
        [RSLogger logError:[NSString stringWithFormat:@"RSMetricsReporter: Failed to report metric, reason: %@", exception.reason]];
    }
}

@end

NSString *const SDKMETRICS_SUBMITTED_EVENTS = @"submitted_events";
NSString *const SDKMETRICS_EVENTS_DISCARDED = @"events_discarded";
NSString *const SDKMETRICS_DM_EVENT = @"dm_event";
NSString *const SDKMETRICS_CM_EVENT = @"cm_event";
NSString *const SDKMETRICS_DM_DISCARD = @"dm_discard";
NSString *const SDKMETRICS_SC_ATTEMPT_SUCCESS = @"sc_attempt_success";
NSString *const SDKMETRICS_SC_ATTEMPT_RETRY = @"sc_attempt_retry";
NSString *const SDKMETRICS_SC_ATTEMPT_ABORT = @"sc_attempt_abort";
NSString *const SDKMETRICS_CM_ATTEMPT_SUCCESS = @"cm_attempt_success";
NSString *const SDKMETRICS_CM_ATTEMPT_RETRY = @"cm_attempt_retry";
NSString *const SDKMETRICS_CM_ATTEMPT_ABORT = @"cm_attempt_abort";

NSString *const SDKMETRICS_TYPE = @"type";
NSString *const SDKMETRICS_OPT_OUT = @"opt_out";
NSString *const SDKMETRICS_SDK_DISABLED = @"sdk_disabled";
NSString *const SDKMETRICS_MSG_SIZE_INVALID = @"msg_size_invalid";
NSString *const SDKMETRICS_BATCH_SIZE_INVALID = @"batch_size_invalid";
NSString *const SDKMETRICS_OUT_OF_MEMORY = @"out_of_memory";
NSString *const SDKMETRICS_MSG_FILTERED = @"msg_filtered";
NSString *const SDKMETRICS_QUEUES = @"queues";
NSString *const SDKMETRICS_MESSAGES = @"messages";
NSString *const SDKMETRICS_DM_DISSENTED = @"dissented";
NSString *const SDKMETRICS_DM_DISABLED = @"disabled";
NSString *const SDKMETRICS_CONTROL_PLANE_URL_INVALID = @"control_plane_url_invalid";
NSString *const SDKMETRICS_DATA_PLANE_URL_INVALID = @"invalid_data_plane_url";
NSString *const SDKMETRICS_SOURCE_DISABLED = @"source_disabled";
NSString *const SDKMETRICS_WRITEKEY_INVALID = @"writekey_invalid";
NSString *const SDKMETRICS_INTEGRATION = @"integration";
NSString *const SDKMETRICS_REQUEST_TIMEOUT = @"request_timeout";
