//
//  RSCloudModeManager.m
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSConfig.h"
#import "RSLogger.h"
#import "RSCloudModeManager.h"
#import "RSNetworkManager.h"
#import "RSNetworkResponse.h"
#import "RSMetricsReporter.h"

@implementation RSCloudModeManager


- (instancetype)initWithConfig:(RSConfig *) config andDBPersistentManager:(RSDBPersistentManager *) dbPersistentManager andNetworkManager:(RSNetworkManager *) networkManager andLock: (NSLock *) lock {
    self = [super init];
    if(self){
        self->dbPersistentManager = dbPersistentManager;
        self->networkManager = networkManager;
        self->config = config;
        self->lock = lock;
        self->cloud_mode_processor_queue = dispatch_queue_create("com.rudder.RSCloudModeManager", NULL);
    }
    return self;
}

- (void) startCloudModeProcessor {
    __weak RSCloudModeManager *weakSelf = self;
    dispatch_async(cloud_mode_processor_queue, ^{
        RSCloudModeManager *strongSelf = weakSelf;
        [RSLogger logDebug:@"RSCloudModeManager: CloudModeProcessor: Starting the Cloud Mode Processor"];
        int sleepCount = 0;
        
        while (YES) {
            [strongSelf->lock lock];
            RSNetworkResponse* response = nil;
            [strongSelf->dbPersistentManager clearOldEventsWithThreshold: strongSelf->config.dbCountThreshold];
            [RSLogger logDebug:@"RSCloudModeManager: CloudModeProcessor: Fetching events to flush to server"];
            RSDBMessage* dbMessage = [strongSelf->dbPersistentManager fetchEventsFromDB:(strongSelf->config.flushQueueSize) ForMode:CLOUDMODE];
            if ((dbMessage.messages.count >= strongSelf->config.flushQueueSize) || (dbMessage.messages.count > 0 && (sleepCount >= strongSelf->config.sleepTimeout))) {
                NSString* payload = [RSCloudModeManager getPayloadFromMessages:dbMessage];
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSCloudModeManager: CloudModeProcessor: Payload: %@", payload]];
                [RSLogger logInfo:[[NSString alloc] initWithFormat:@"RSCloudModeManager: CloudModeProcessor: EventCount: %lu", (unsigned long)dbMessage.messageIds.count]];
                [RSMetricsReporter report:SDKMETRICS_CM_EVENT forMetricType:COUNT withProperties:@{SDKMETRICS_TYPE: SDKMETRICS_MESSAGES} andValue:(float)dbMessage.messages.count];
                if (payload != nil) {
                    response = [strongSelf->networkManager sendNetworkRequest:payload toEndpoint:BATCH_ENDPOINT withRequestMethod:POST];
                    if (response.state == NETWORK_SUCCESS) {
                        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSCloudModeManager: CloudModeProcessor: Updating status as CLOUDMODEPROCESSING DONE for events (%@)",[RSUtils getCSVString:dbMessage.messageIds]]];
                        [RSMetricsReporter report:SDKMETRICS_CM_ATTEMPT_SUCCESS forMetricType:COUNT withProperties:nil andValue:(float)dbMessage.messages.count];
                        [strongSelf->dbPersistentManager updateEventsWithIds:dbMessage.messageIds withStatus:CLOUD_MODE_PROCESSING_DONE];
                        [strongSelf->dbPersistentManager clearProcessedEventsFromDB];
                        sleepCount = 0;
                    }
                }
            }
            [strongSelf->lock unlock];
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSCloudModeManager: CloudModeProcessor: cloudModeSleepCount: %d", sleepCount]];
            sleepCount += 1;
            if(response == nil) {
                usleep(1000000);
            } else if (response.state == WRONG_WRITE_KEY) {
                [RSLogger logError:@"RSCloudModeManager: CloudModeProcessor: Wrong WriteKey. Aborting the Cloud Mode Processor"];
                break;
            } else if (response.state == INVALID_URL) {
                [RSLogger logError:@"RSCloudModeManager: CloudModeProcessor: Invalid Data Plane URL. Aborting the Cloud Mode Processor"];
                [RSMetricsReporter report:SDKMETRICS_CM_ATTEMPT_ABORT forMetricType:COUNT withProperties:@{SDKMETRICS_TYPE: SDKMETRICS_DATA_PLANE_URL_INVALID} andValue:1];
                break;
            }
            else if (response.state == NETWORK_ERROR) {
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSCloudModeManager: CloudModeProcessor: Retrying in: %d s", abs(sleepCount - strongSelf->config.sleepTimeout)]];
                [RSMetricsReporter report:SDKMETRICS_CM_ATTEMPT_RETRY forMetricType:COUNT withProperties:nil andValue:1];
                usleep(abs(sleepCount - strongSelf->config.sleepTimeout) * 1000000);
            }
        }
    });
}

+ (NSString*) getPayloadFromMessages: (RSDBMessage*)dbMessage{
    if ([RSUtils isDBMessageEmpty:dbMessage]) {
        [RSLogger logDebug:@"Payload construction aborted because the dbMessage is empty."];
        return nil;
    }
    NSMutableArray<NSString *>* messages = dbMessage.messages;
    NSMutableArray<NSString *>* messageIds = dbMessage.messageIds;
    NSMutableArray<NSString *> *batchMessageIds = [[NSMutableArray alloc] init];
    NSString* sentAt = [RSUtils getTimestamp];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSCloudModeManager: getPayloadFromMessages: RecordCount: %lu", (unsigned long)messages.count]];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSCloudModeManager: getPayloadFromMessages: sentAtTimeStamp: %@", sentAt]];
    
    NSMutableString* json = [[NSMutableString alloc] init];
    [json appendString:@"{"];
    [json appendFormat:@"\"sentAt\":\"%@\",", sentAt];
    [json appendString:@"\"batch\":["];
    unsigned int totalBatchSize = [RSUtils getUTF8Length:json] + 2; // we add 2 characters at the end
    NSMutableString* batchMessage = [[NSMutableString alloc] init];
    for (int index = 0; index < messages.count; index++) {
        NSMutableString* message = [[NSMutableString alloc] initWithString:messages[index]];
        long length = message.length;
        message = [[NSMutableString alloc] initWithString:[message substringWithRange:NSMakeRange(0, (length-1))]];
        [message appendFormat:@",\"sentAt\":\"%@\"},", sentAt];
        // add message size to batch size
        totalBatchSize += [RSUtils getUTF8Length:message];
        // check totalBatchSize
        if(totalBatchSize > MAX_BATCH_SIZE) {
            [RSLogger logDebug:[NSString stringWithFormat:@"RSCloudModeManager: getPayloadFromMessages: MAX_BATCH_SIZE reached at index: %i | Total: %i",index, totalBatchSize]];
            [RSMetricsReporter report:SDKMETRICS_EVENTS_DISCARDED forMetricType:COUNT withProperties:@{SDKMETRICS_TYPE: SDKMETRICS_BATCH_SIZE_INVALID} andValue:1];
            break;
        }
        [batchMessage appendString:message];
        [batchMessageIds addObject:messageIds[index]];
    }
    // When empty batch is sent to the server it trigger Invalid JSON error. Hence it is necessary to ensure that batch is not empty.
    if ([RSUtils isEmptyString:batchMessage]) {
        [RSLogger logDebug:@"Payload construction aborted because the batch message is empty."];
        return nil;
    }
    [json appendString:batchMessage];
    if([json characterAtIndex:[json length]-1] == ',') {
        // remove trailing ','
        [json deleteCharactersInRange:NSMakeRange([json length]-1, 1)];
    }
    [json appendString:@"]}"];
    // retain all events that are part of the current event
    dbMessage.messageIds = batchMessageIds;
    return [json copy];
}

@end
