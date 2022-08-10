//
//  RSDeviceModeTransformationManager.m
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSDeviceModeTransformationManager.h"

@implementation RSDeviceModeTransformationManager

int const DMT_BATCH_SIZE = 12;

static dispatch_queue_t transformation_processor_queue;

- (instancetype)initWithConfig:(RSConfig *) config andDBPersistentManager:(RSDBPersistentManager *) dbPersistentManager andDeviceModeManager:(RSDeviceModeManager *) deviceModeManager andNetworkManager:(RSNetworkManager *) networkManager  {
    self = [super init];
    if(self) {
        if (transformation_processor_queue == nil) {
            transformation_processor_queue = dispatch_queue_create("com.rudder.TransformationProcessorQueue", NULL);
        }
        self->config = config;
        self->dbPersistentManager = dbPersistentManager;
        self->networkManager = networkManager;
        self->deviceModeManager = deviceModeManager;
    }
    return self;
}


- (void) startTransformationProcessor {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(transformationProcessor) userInfo:nil repeats:YES];
    });
}

int deviceModeSleepCount = 0;

- (void) transformationProcessor {
    __weak RSDeviceModeTransformationManager *weakSelf = self;
    dispatch_sync(transformation_processor_queue, ^{
        RSDeviceModeTransformationManager *strongSelf = weakSelf;
        [RSLogger logDebug:@"RSDeviceModeTransformationManager: initiateTransformationProcessor: Transformation processor started"];
        [RSLogger logDebug:@"RSDeviceModeTransformationManager: initiateTransformationProcessor: Fetching events to flush to transformations server"];
        int deviceModeEventsCount = [strongSelf->dbPersistentManager getDBRecordCountForMode:DEVICEMODE];
        
        // the flow would get started only if the number of eligible events for device mode transformation is greater than DMT_BATCH_SIZE (OR) if the sleepCount is greater than the sleepTimeOut and number of eligible events for Device Mode is >0
        if (deviceModeEventsCount >= DMT_BATCH_SIZE || ((deviceModeSleepCount >= [strongSelf->config sleepTimeout]) && deviceModeEventsCount > 0)) {
            do {
                RSDBMessage* dbMessage = [strongSelf->dbPersistentManager fetchEventsFromDB:DMT_BATCH_SIZE ForMode:DEVICEMODE];
                NSString* payload = [self __getPayloadForTransformation:dbMessage];
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Payload: %@", payload]];
                [RSLogger logInfo:[[NSString alloc] initWithFormat:@"EventCount: %lu", (unsigned long)dbMessage.messageIds.count]];
                NSDictionary<NSString*, NSString*>* response = [self->networkManager sendNetworkRequest:payload toEndpoint:TRANSFORM_ENDPOINT];
                int errResp = [response[STATUS] intValue];
                NSString* responsePayload = response[RESPONSE];
                if (errResp == WRONGWRITEKEY) {
                    [RSLogger logDebug:@"RSEventRepository: initiateTransformationProcessor: Wrong WriteKey. Aborting."];
                    break;
                } else if (errResp == NETWORKERROR) {
                    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSEventRepository: initiateTransformationProcessor: Retrying in: %d s", abs(deviceModeSleepCount - strongSelf->config.sleepTimeout)]];
                    usleep(abs(deviceModeSleepCount - strongSelf->config.sleepTimeout) * 1000000);
                }
                else {
                    deviceModeSleepCount = 0;
                    id object = [RSUtils deSerializeJSONString:responsePayload];
                    if(object != nil && [object isKindOfClass:[NSDictionary class]]) {
                        NSArray* transformedBatches = object[@"transformedBatch"];
                        for(NSDictionary* transformedDestination in transformedBatches) {
                            NSString* destinationId = transformedDestination[@"id"];
                            NSArray* transformedPayloads = [transformedDestination[@"payload"] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
                                return [a[@"orderNo"] compare:b[@"orderNo"]];
                            }];
                            [strongSelf->deviceModeManager dumpTransformedEvents:transformedPayloads ToDestination:destinationId];
                        }
                        [strongSelf->dbPersistentManager updateEventsWithIds:dbMessage.messageIds withStatus:DEVICEMODEPROCESSINGDONE];
                        [strongSelf->dbPersistentManager clearProcessedEventsFromDB];
                    }
                }
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSEventRepository: initiateTransformationProcessor: SleepCount: %d", deviceModeSleepCount]];
            }while([strongSelf->dbPersistentManager getDBRecordCountForMode:DEVICEMODE] > 0);
        }
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSEventRepository: initiateTransformationProcessor: deviceModeSleepCount: %d", deviceModeSleepCount]];
        deviceModeSleepCount += 1;
    });
}

-(NSString*) __getPayloadForTransformation:(RSDBMessage *)dbMessage {
    NSMutableArray<NSString *>* messages = dbMessage.messages;
    NSMutableArray<NSString *>* messageIds = dbMessage.messageIds;
    NSMutableArray<NSString *> *batchMessageIds = [[NSMutableArray alloc] init];
    NSString* sentAt = [RSUtils getTimestamp];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RecordCount: %lu", (unsigned long)messages.count]];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"sentAtTimeStamp: %@", sentAt]];
    
    NSMutableString* jsonPayload = [[NSMutableString alloc] init];
    [jsonPayload appendString:@"{"];
    [jsonPayload appendString:@"\"batch\":"];
    [jsonPayload appendString:@"["];
    
    unsigned int totalBatchSize = [RSUtils getUTF8Length:jsonPayload] + 1; // we add 1 characters at the end
    for (int index = 0; index < messages.count; index++) {
        NSMutableString* message = [[NSMutableString alloc] init];
        [message appendString:@"{"];
        [message appendFormat:@"\"orderNo\": %@,", messageIds[index]];
        [message appendFormat:@"\"event\": %@", messages[index]];
        [message appendFormat:@"},"];
        //  add message size to batch size
        totalBatchSize += [RSUtils getUTF8Length:message];
        // check totalBatchSize
        if(totalBatchSize > MAX_BATCH_SIZE) {
            [RSLogger logDebug:[NSString stringWithFormat:@"MAX_BATCH_SIZE reached at index: %i | Total: %i",index, totalBatchSize]];
            break;
        }
        [jsonPayload appendString:message];
        [batchMessageIds addObject:messageIds[index]];
    }
    if([jsonPayload characterAtIndex:[jsonPayload length]-1] == ',') {
        // remove trailing ','
        [jsonPayload deleteCharactersInRange:NSMakeRange([jsonPayload length]-1, 1)];
    }
    [jsonPayload appendString:@"]"];
    [jsonPayload appendString:@"}"];
    // retain all events that are part of the current event
    dbMessage.messageIds = batchMessageIds;
    return [jsonPayload copy];
}
@end
