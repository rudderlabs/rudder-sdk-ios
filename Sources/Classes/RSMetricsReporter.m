//
//  RSMetricsReporter.m
//  Rudder
//
//  Created by Pallab Maiti on 20/07/23.
//

#import "RSMetricsReporter.h"
#import "RSConstants.h"

@import MetricsReporter;

@implementation RSMetricsReporter

static RSMetricsReporter* _instance;
static dispatch_queue_t queue;
RSMetricsClient * _Nullable metricsClient;

+ (instancetype)initiateWithWriteKey:(NSString *)writeKey andConfig:(RSConfig *)config {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] initWithWriteKey:writeKey andConfig:config];
        });
    }
    return _instance;
}

- (instancetype)initWithWriteKey:(NSString *)writeKey andConfig:(RSConfig *)config {
    self = [super init];
    if (self) {
        RSMetricConfiguration *configuration = [[RSMetricConfiguration alloc] initWithLogLevel:config.logLevel writeKey:writeKey sdkVersion:RS_VERSION];
        metricsClient = [[RSMetricsClient alloc] initWithConfiguration:configuration];
    }
    return self;
}

+ (void)report:(NSString *)metricName forMetricType:(METRIC_TYPE)metricType withProperties:(NSDictionary * _Nullable )properties andValue:(float)value {
    switch (metricType) {
        case COUNT: {
            RSCount *count = [[RSCount alloc] initWithName:metricName labels:properties value:(int)value];
            if (metricsClient != nil)
                [metricsClient process:count];
        }
            break;
        case GAUGE: {
            RSGauge *gauge = [[RSGauge alloc] initWithName:metricName labels:properties value:value];
            if (metricsClient != nil)
                [metricsClient process:gauge];
        }
            break;
        default:
            break;
    }
}

NSString *const SUBMITTED_EVENTS = @"submitted_events";
NSString *const EVENTS_DISCARDED = @"events_discarded";
NSString *const DM_EVENT = @"dm_event";
NSString *const CM_EVENT = @"cm_event";
NSString *const DM_DISCARD = @"dm_discard";
NSString *const SC_ATTEMPT_SUCCESS = @"sc_attempt_success";
NSString *const SC_ATTEMPT_RETRY = @"sc_attempt_retry";
NSString *const SC_ATTEMPT_ABORT = @"sc_attempt_abort";
NSString *const CM_ATTEMPT_SUCCESS = @"cm_attempt_success";
NSString *const CM_ATTEMPT_RETRY = @"cm_attempt_retry";
NSString *const CM_ATTEMPT_ABORT = @"cm_attempt_abort";

NSString *const TYPE = @"type";
NSString *const OPT_OUT = @"opt_out";
NSString *const SDK_DISABLED = @"sdk_disabled";
NSString *const MSG_SIZE_INVALID = @"msg_size_invalid";
NSString *const OUT_OF_MEMORY = @"out_of_memory";
NSString *const MSG_FILTERED = @"msg_filtered";
NSString *const QUEUES = @"queues";
NSString *const MESSAGES = @"messages";
NSString *const DM_DISSENTED = @"dissented";
NSString *const DM_DISABLED = @"disabled";
NSString *const CONTROL_PLANE_URL_INVALID = @"control_plane_url_invalid";
NSString *const SOURCE_DISABLED = @"source_disabled";
NSString *const WRITEKEY_INVALID = @"writekey_invalid";
NSString *const INTEGRATION = @"integration";

@end
