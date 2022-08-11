//
//  RSDeviceModeTransformationManager.m
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSDeviceModeTransformationManager.h"
#import "RSNetworkResponse.h"

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
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: initiateTransformationProcessor: Payload: %@", payload]];
                [RSLogger logInfo:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: initiateTransformationProcessor: EventCount: %lu", (unsigned long)dbMessage.messageIds.count]];
                RSNetworkResponse* response = [self->networkManager sendNetworkRequest:payload toEndpoint:TRANSFORM_ENDPOINT withRequestMethod:POST];
                NSString* responsePayload = response.responsePayload;
                if (response.state == WRONG_WRITE_KEY) {
                    [RSLogger logDebug:@"RSDeviceModeTransformationManager: initiateTransformationProcessor: Wrong WriteKey. Aborting."];
                    break;
                } else if (response.state == NETWORK_ERROR) {
                    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: initiateTransformationProcessor: Retrying in: %d s", abs(deviceModeSleepCount - strongSelf->config.sleepTimeout)]];
                    usleep(abs(deviceModeSleepCount - strongSelf->config.sleepTimeout) * 1000000);
                } else if (response.state == RESOURCE_NOT_FOUND) {  // So when the customer is not eligible for Device Mode Transformations, we get RESOURCE_NOT_FOUND, and in this case we will dump the original methods itself to the factories.
                    deviceModeSleepCount = 0;
                    id object = [RSUtils deSerializeJSONString:payload];
                    if(object !=nil && [object isKindOfClass:[NSDictionary class]]) {
                        NSArray* originalBatch = object[@"batch"];
                        if(originalBatch != nil && originalBatch.count > 0) {
                            [strongSelf->deviceModeManager dumpOriginalEvents:originalBatch];
                        }
                    }
                    [strongSelf->dbPersistentManager updateEventsWithIds:dbMessage.messageIds withStatus:DEVICE_MODE_PROCESSING_DONE];
                    [strongSelf->dbPersistentManager clearProcessedEventsFromDB];
                } else {
                    deviceModeSleepCount = 0;
                    id object = [RSUtils deSerializeJSONString:responsePayload];
                    if(object != nil && [object isKindOfClass:[NSDictionary class]]) {
                        NSArray* transformedBatch = object[@"transformedBatch"];
                        if(transformedBatch != nil && transformedBatch.count > 0) {
                            for(NSDictionary* transformedDestination in transformedBatch) {
                                NSString* destinationId = transformedDestination[@"id"];
                                NSArray* transformedPayloads = transformedDestination[@"payload"];
                                [transformedPayloads sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
                                    return [a[@"orderNo"] compare:b[@"orderNo"]];
                                }];
                                if(transformedPayloads != nil && transformedPayloads.count > 0 && destinationId != nil) {
                                    [strongSelf->deviceModeManager dumpTransformedEvents:transformedPayloads ToDestination:destinationId];
                                }
                            }
                        }
                    }
                    [strongSelf->dbPersistentManager updateEventsWithIds:dbMessage.messageIds withStatus:DEVICE_MODE_PROCESSING_DONE];
                    [strongSelf->dbPersistentManager clearProcessedEventsFromDB];
                }
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: initiateTransformationProcessor: SleepCount: %d", deviceModeSleepCount]];
            }while([strongSelf->dbPersistentManager getDBRecordCountForMode:DEVICEMODE] > 0);
        }
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: initiateTransformationProcessor: deviceModeSleepCount: %d", deviceModeSleepCount]];
        deviceModeSleepCount += 1;
    });
}

-(NSString*) __getPayloadForTransformation:(RSDBMessage *)dbMessage {
    NSMutableArray<NSString *>* messages = dbMessage.messages;
    NSMutableArray<NSString *>* messageIds = dbMessage.messageIds;
    NSMutableArray<NSString *> *batchMessageIds = [[NSMutableArray alloc] init];
    NSString* sentAt = [RSUtils getTimestamp];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: getPayloadForTransformation: RecordCount: %lu", (unsigned long)messages.count]];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: getPayloadForTransformation: sentAtTimeStamp: %@", sentAt]];
    
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
            [RSLogger logDebug:[NSString stringWithFormat:@"RSDeviceModeTransformationManager: getPayloadForTransformation: MAX_BATCH_SIZE reached at index: %i | Total: %i",index, totalBatchSize]];
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
