//
//  RSDeviceModeTransformationManager.m
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSDeviceModeTransformationManager.h"

int const DMT_BATCH_SIZE = 12;
int const MAX_RETRIES = 2;  // Maximum number of retries
int const MAX_DELAY = 1000; // Maximum delay in milliseconds

@implementation RSDeviceModeTransformationManager

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
        [RSLogger logDebug:@"RSDeviceModeTransformationManager: startTransformationProcessor: Transformation processor started"];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(transformationProcessor) userInfo:nil repeats:YES];
    });
}

int deviceModeSleepCount = 0;

- (void) transformationProcessor {
    __weak RSDeviceModeTransformationManager *weakSelf = self;
    dispatch_sync(transformation_processor_queue, ^{
        RSDeviceModeTransformationManager *strongSelf = weakSelf;
        [RSLogger logDebug:@"RSDeviceModeTransformationManager: TransformationProcessor: Fetching events to flush to transformations server"];
        int deviceModeEventsCount = [strongSelf->dbPersistentManager getDBRecordCountForMode:DEVICEMODE];
        
        // the flow would get started only if the number of eligible events for device mode transformation is greater than DMT_BATCH_SIZE (OR) if the sleepCount is greater than the sleepTimeOut and number of eligible events for Device Mode is >0
        if (deviceModeEventsCount >= DMT_BATCH_SIZE || ((deviceModeSleepCount >= [strongSelf->config sleepTimeout]) && deviceModeEventsCount > 0)) {
            int retryCount = 0;
            do {
                RSDBMessage* dbMessage = [strongSelf->dbPersistentManager fetchEventsFromDB:DMT_BATCH_SIZE ForMode:DEVICEMODE];
                RSTransformationRequest* request = [strongSelf __getDeviceModeTransformationRequest:dbMessage];
                NSString* payload = [RSUtils serialize:[request toDict]];
                if(payload == nil) {
                    [RSLogger logDebug:@"RSDeviceModeTransformationManager: TransformationProcessor: Payload is nil. Aborting the TransformationProcessor."];
                    break;
                }
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: TransformationProcessor: Payload: %@", payload]];
                [RSLogger logInfo:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: TransformationProcessor: EventCount: %lu", (unsigned long)dbMessage.messageIds.count]];
                RSNetworkResponse* response = [strongSelf->networkManager sendNetworkRequest:payload toEndpoint:TRANSFORM_ENDPOINT withRequestMethod:POST];
                NSString* responsePayload = response.responsePayload;
                if (response.state == WRONG_WRITE_KEY) {
                    [RSLogger logDebug:@"RSDeviceModeTransformationManager: TransformationProcessor: Wrong WriteKey. Aborting the TransformationProcessor."];
                    break;
                } else if (response.state == INVALID_URL) {
                    [RSLogger logDebug:@"RSDeviceModeTransformationManager: TransformationProcessor: Invalid Data Plane URL. Aborting the TransformationProcessor"];
                    break;
                } else if (response.state == NETWORK_UNAVAILABLE) {
                    [RSLogger logDebug:@"RSDeviceModeTransformationManager: TransformationProcessor: Network Un-available. Aborting the TransformationProcessor"];
                    break;
                } else if (response.state == BAD_REQUEST) {
                    [RSLogger logWarn:@"RSDeviceModeTransformationManager: TransformationProcessor: Bad Request, dumping back the original events to the factories"];
                    [strongSelf->deviceModeManager dumpOriginalEventsOnTransformationError:request.batch];
                    [strongSelf completeDeviceModeEventProcessing:dbMessage];
                }
                else if (response.state == NETWORK_ERROR) {
                    NSInteger delay = MIN((1 << retryCount) * 500, MAX_DELAY); // Exponential backoff
                    if (retryCount++ == MAX_RETRIES) {
                        retryCount = 0;
                        deviceModeSleepCount = 0;
                        [RSLogger logWarn:[NSString stringWithFormat:@"RSDeviceModeTransformationManager: TransformationProcessor: Failed to transform events even after %d retries, hence dumping back the original events to the factories", MAX_RETRIES]];
                        [strongSelf->deviceModeManager dumpOriginalEventsOnTransformationError:request.batch];
                        [strongSelf completeDeviceModeEventProcessing:dbMessage];
                    } else {
                        [RSLogger logDebug:[NSString stringWithFormat:@"RSDeviceModeTransformationManager: TransformationProcessor: Network Error, Retrying again in %.2f s", (NSTimeInterval)delay/1000]];
                        usleep((useconds_t)delay* 1000);
                    }
                } else if (response.state == RESOURCE_NOT_FOUND) {  // So when the customer is not eligible for Device Mode Transformations, we get RESOURCE_NOT_FOUND, and in this case we will dump the original methods itself to the factories.
                    deviceModeSleepCount = 0;
                    [strongSelf->deviceModeManager dumpOriginalEventsOnTransformationsFeatureDisabled:request.batch];
                    [strongSelf completeDeviceModeEventProcessing:dbMessage];
                } else {
                    deviceModeSleepCount = 0;
                    id object = [RSUtils deserialize:responsePayload];
                    if(object != nil && [object isKindOfClass:[NSDictionary class]]) {
                        NSArray* transformedBatch = object[@"transformedBatch"];
                        if(transformedBatch != nil && transformedBatch.count > 0) {
                            for(NSDictionary* transformedDestination in transformedBatch) {
                                NSString* destinationId = transformedDestination[@"id"];
                                NSArray* transformedPayloads = transformedDestination[@"payload"];
                                transformedPayloads = [transformedPayloads sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
                                    return [a[@"orderNo"] compare:b[@"orderNo"]];
                                }];
                                if(transformedPayloads != nil && transformedPayloads.count > 0 && destinationId != nil) {
                                    [strongSelf->deviceModeManager dumpTransformedEvents:transformedPayloads toDestinationId:destinationId whereOriginalPayload:request];
                                }
                            }
                        }
                    }
                    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: TransformationProcessor: Updating status as DEVICE_MODE_PROCESSING DONE for events (%@)",[RSUtils getCSVStringFromArray:dbMessage.messageIds]]];
                    [strongSelf->dbPersistentManager updateEventsWithIds:dbMessage.messageIds withStatus:DEVICE_MODE_PROCESSING_DONE];
                    [strongSelf->dbPersistentManager clearProcessedEventsFromDB];
                }
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: TransformationProcessor: SleepCount: %d", deviceModeSleepCount]];
            }while([strongSelf->dbPersistentManager getDBRecordCountForMode:DEVICEMODE] > 0);
        }
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: TransformationProcessor: deviceModeSleepCount: %d", deviceModeSleepCount]];
        deviceModeSleepCount += 1;
    });
}

- (RSTransformationRequest *) __getDeviceModeTransformationRequest:(RSDBMessage *) dbMessage {
    RSTransformationRequest* request = [[RSTransformationRequest alloc] init];
    NSString* authToken = [[RSPreferenceManager getInstance] getAuthToken];
    if(authToken!= nil && [authToken length]!=0) {
        RSTransformationMetadata* metadata = [[RSTransformationMetadata alloc] init];
        metadata.customAuthorization = authToken;
        request.metadata = metadata;
    }
    NSMutableArray<NSString *>* messages = dbMessage.messages;
    NSMutableArray<NSString *>* messageIds = dbMessage.messageIds;
    for(int i=0; i<messages.count; i++) {
        id object = [RSUtils deserialize:messages[i]];
        if (object != nil && [object isKindOfClass:[NSDictionary class]]) {
            RSMessage* message = [[RSMessage alloc] initWithDict:object];
            NSArray<NSString *>* destinationIds = [self getDestinationIdsWithTransformationsForMessage:message];
            if(destinationIds== nil || [destinationIds count]==0) continue;
            RSTransformationEvent* transformationEvent = [[RSTransformationEvent alloc] init];
            transformationEvent.event = message;
            transformationEvent.destinationIds = destinationIds;
            transformationEvent.orderNo = [NSNumber numberWithInt:[messageIds[i] intValue]];
            [request.batch addObject:transformationEvent];
        }
    }
    return request;
}

-(NSArray<NSString*>*) getDestinationIdsWithTransformationsForMessage:(RSMessage *) message {
    return [self->deviceModeManager getDestinationIdsWithTransformationStatus:ENABLED fromMessage:message];
}


- (void)completeDeviceModeEventProcessing:(RSDBMessage *)dbMessage {
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeTransformationManager: TransformationProcessor: Updating status as DEVICE_MODE_PROCESSING DONE for events (%@)",[RSUtils getCSVStringFromArray:dbMessage.messageIds]]];
    [self->dbPersistentManager updateEventsWithIds:dbMessage.messageIds withStatus:DEVICE_MODE_PROCESSING_DONE];
    [self->dbPersistentManager clearProcessedEventsFromDB];
}


@end
