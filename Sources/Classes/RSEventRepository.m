//
//  EventRepository.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSEventRepository.h"
#import "RSElementCache.h"
#import "RSUtils.h"
#import "RSLogger.h"
#import "RSDBPersistentManager.h"
#import "WKInterfaceController+RSScreen.h"
#import "UIViewController+RSScreen.h"


NSString* const STATUS = @"STATUS";
NSString* const RESPONSE = @"RESPONSE";
int const DMT_BATCH_SIZE = 12;
static id UPLOAD_LOCK;
static RSEventRepository* _instance;
static dispatch_queue_t flush_processor_queue;
static dispatch_queue_t transformation_processor_queue;

@implementation RSEventRepository

+ (instancetype)initiate:(NSString *)writeKey config:(RSConfig *) config {
    if (_instance == nil) {
        UPLOAD_LOCK = [[NSObject alloc] init];
        if (flush_processor_queue == nil) {
            flush_processor_queue = dispatch_queue_create("com.rudder.FlushProcessorQueue", NULL);
        }
        if (transformation_processor_queue == nil) {
            transformation_processor_queue = dispatch_queue_create("com.rudder.TransformationProcessorQueue", NULL);
        }
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init:writeKey config:config];
        });
    }
    return _instance;
}

+ (instancetype) getInstance {
    return _instance;
}

/*
 * constructor to be called from RSClient internally.
 * -- tasks to be performed
 * 1. persist the value of config
 * 2. initiate RSElementCache
 * 3. initiate DBPersistentManager for SQLite operations
 * 4. initiate RSServerConfigManager
 * 5. start processor thread
 * 6. initiate factories
 * */
- (instancetype)init : (NSString*) _writeKey config:(RSConfig*) _config {
    self = [super init];
    if (self) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: writeKey: %@", _writeKey]];
        
        self->firstForeGround = YES;
        self->areFactoriesInitialized = NO;
        self->isSDKEnabled = YES;
        self->isSDKInitialized = NO;
        
        writeKey = _writeKey;
        config = _config;
        
        if(config.enableBackgroundMode) {
            [RSLogger logDebug:@"EventRepository: Enabling Background Mode"];
#if !TARGET_OS_WATCH
            backgroundTask = UIBackgroundTaskInvalid;
            [self registerBackGroundTask];
#else
            [self askForAssertionWithSemaphore];
#endif
        }
        
        [RSLogger logDebug:@"EventRepository: setting up flush"];
        [self setUpFlush];
        NSData *authData = [[[NSString alloc] initWithFormat:@"%@:", _writeKey] dataUsingEncoding:NSUTF8StringEncoding];
        authToken = [authData base64EncodedStringWithOptions:0];
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: authToken: %@", authToken]];
        
        [RSLogger logDebug:@"EventRepository: initiating element cache"];
        [RSElementCache initiate];
        
        [RSLogger logDebug:@"EventRepository: initiating eventReplayMessage queue"];
        self->eventReplayMessage = [[NSMutableDictionary alloc] init];
        
        [self setAnonymousIdToken];
        
        [RSLogger logDebug:@"EventRepository: initiating dbPersistentManager"];
        self->dbpersistenceManager = [[RSDBPersistentManager alloc] init];
        [self->dbpersistenceManager createTables];
        [self->dbpersistenceManager checkForMigrations];
        
        [RSLogger logDebug:@"EventRepository: initiating server config manager"];
        self->configManager = [[RSServerConfigManager alloc] init:writeKey rudderConfig:config];
        
        [RSLogger logDebug:@"EventRepository: initiating preferenceManager"];
        self->preferenceManager = [RSPreferenceManager getInstance];
        
        [RSLogger logDebug:@"EventRepository: initiating processor and factories"];
        [self __initiateSDK];
        
        if (config.trackLifecycleEvents) {
            [RSLogger logDebug:@"EventRepository: tracking application lifecycle"];
            [self __checkApplicationUpdateStatus];
        }
        
        if (config.recordScreenViews) {
            [RSLogger logDebug:@"EventRepository: starting automatic screen records"];
            [self __prepareScreenRecorder];
        }
    }
    return self;
}

- (void) setAnonymousIdToken {
    NSData *anonymousIdData = [[[NSString alloc] initWithFormat:@"%@:", [RSElementCache getAnonymousId]] dataUsingEncoding:NSUTF8StringEncoding];
    dispatch_sync([RSContext getQueue], ^{
        self->anonymousIdToken = [anonymousIdData base64EncodedStringWithOptions:0];
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: anonymousIdToken: %@", self->anonymousIdToken]];
    });
}

- (void) __initiateSDK {
    __weak RSEventRepository *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RSEventRepository *strongSelf = weakSelf;
        int retryCount = 0;
        while (strongSelf->isSDKInitialized == NO && retryCount <= 5) {
            RSServerConfigSource *serverConfig = [strongSelf->configManager getConfig];
            int receivedError =[strongSelf->configManager getError];
            if (serverConfig != nil) {
                // initiate the processor if the source is enabled
                dispatch_sync([RSContext getQueue], ^{
                    strongSelf->isSDKEnabled = serverConfig.isSourceEnabled;
                });
                if  (strongSelf->isSDKEnabled) {
                    [RSLogger logDebug:@"EventRepository: initiating processor"];
                    [strongSelf __initiateProcessor];
                    
                    // initialize integrationOperationMap
                    strongSelf->integrationOperationMap = [[NSMutableDictionary alloc] init];
                    
                    // initiate the native SDK factories if destinations are present
                    if (serverConfig.destinations != nil && serverConfig.destinations.count > 0) {
                        [RSLogger logDebug:@"EventRepository: initiating factories"];
                        strongSelf->destinationsWithTransformationsEnabled = [strongSelf->configManager getDestinationsWithTransformationsEnabled];
                        // initaiting the transformation processor only if there are any device mode destinations with transformations enabled
                        if([strongSelf-> destinationsWithTransformationsEnabled count] > 0){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(initiateTransformationProcessor) userInfo:nil repeats:YES];
                            });
                        }
                        [strongSelf __initiateFactories: serverConfig.destinations];
                        [RSLogger logDebug:@"EventRepository: initiating event filtering plugin for device mode destinations"];
                        strongSelf->eventFilteringPlugin = [[RSEventFilteringPlugin alloc] init:serverConfig.destinations];
                        
                    } else {
                        [RSLogger logDebug:@"EventRepository: no device mode present"];
                    }
                    
                    // initiate custom factories
                    [strongSelf __initiateCustomFactories];
                    [strongSelf __replayMessageQueue];
                    strongSelf->areFactoriesInitialized = YES;
                    
                } else {
                    [RSLogger logDebug:@"EventRepository: source is disabled in your Dashboard"];
                    [strongSelf->dbpersistenceManager flushEventsFromDB];
                }
                strongSelf->isSDKInitialized = YES;
            } else if(receivedError==2){
                retryCount= 6;
                [RSLogger logError:@"WRONG WRITE KEY"];
            }else {
                retryCount += 1;
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"server config is null. retrying in %ds.", 2 * retryCount]];
                usleep(1000000 * 2 * retryCount);
            }
        }
    });
}

- (void) __initiateFactories : (NSArray*) destinations {
    if (self->config == nil || config.factories == nil || config.factories.count == 0) {
        [RSLogger logInfo:@"EventRepository: No native SDK is found in the config"];
        return;
    } else {
        if (destinations.count == 0) {
            [RSLogger logInfo:@"EventRepository: No native SDK factory is found in the server config"];
        } else {
            NSMutableDictionary<NSString*, RSServerDestination*> *destinationDict = [[NSMutableDictionary alloc] init];
            for (RSServerDestination *destination in destinations) {
                [destinationDict setObject:destination forKey:destination.destinationDefinition.displayName];
            }
            for (id<RSIntegrationFactory> factory in self->config.factories) {
                RSServerDestination *destination = [destinationDict objectForKey:factory.key];
                if (destination != nil && destination.isDestinationEnabled == YES) {
                    NSDictionary *destinationConfig = destination.destinationConfig;
                    if (destinationConfig != nil) {
                        id<RSIntegration> nativeOp = [factory initiate:destinationConfig client:[RSClient sharedInstance] rudderConfig:self->config];
                        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Initiating native SDK factory %@", factory.key]];
                        [integrationOperationMap setValue:nativeOp forKey:factory.key];
                        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Initiated native SDK factory %@", factory.key]];
                        // put native sdk initialization callback
                    }
                }
            }
        }
    }
}

- (void) __initiateCustomFactories {
    if (self->config == nil || config.customFactories == nil || config.customFactories.count == 0) {
        [RSLogger logInfo:@"EventRepository: initiateCustomFactories: No custom factory found"];
        return;
    }
    for (id<RSIntegrationFactory> factory in self->config.customFactories) {
        id<RSIntegration> nativeOp = [factory initiate:@{} client:[RSClient sharedInstance] rudderConfig:self->config];
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Initiating custom factory %@", factory.key]];
        [self->integrationOperationMap setValue:nativeOp forKey:factory.key];
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Initiated custom SDK factory %@", factory.key]];
        // put custom sdk initalization callback
    }
}

int deviceModeSleepCount = 0;

- (void) initiateTransformationProcessor {
    __weak RSEventRepository *weakSelf = self;
    dispatch_sync(transformation_processor_queue, ^{
        RSEventRepository *strongSelf = weakSelf;
        [RSLogger logDebug:@"RSEventRepository: initiateTransformationProcessor: Transformation processor started"];
        [RSLogger logDebug:@"RSEventRepository: initiateTransformationProcessor: Fetching events to flush to transformations server"];
        int deviceModeEventsCount = [strongSelf->dbpersistenceManager getDBRecordCountForMode:DEVICEMODE];
        
        // the flow would get started only if the number of eligible events for device mode transformation is greater than DMT_BATCH_SIZE (OR) if the sleepCount is greater than the sleepTimeOut and number of eligible events for Device Mode is >0
        if (deviceModeEventsCount >= DMT_BATCH_SIZE || ((deviceModeSleepCount >= [strongSelf->config sleepTimeout]) && deviceModeEventsCount>=0)) {
            do {
                RSDBMessage* _dbMessage = [strongSelf->dbpersistenceManager fetchEventsFromDB:DMT_BATCH_SIZE ForMode:DEVICEMODE];
                NSDictionary<NSString*, NSString*>* response = [strongSelf flushEventsToTransformationServer:_dbMessage];
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
                        for(NSDictionary* transformedBatch in transformedBatches) {
                            NSDictionary* destinationObject = transformedBatch[@"destination"];
                            NSString* destinationId = destinationObject[@"id"];
                            NSString* status = destinationObject[@"status"];
                            NSArray* transformedPayloads = [destinationObject[@"payload"] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *a, NSDictionary *b) {
                                return [a[@"orderNo"] compare:b[@"orderNo"]];
                            }];
                            if([status isEqualToString:@"200"]) {
                                [strongSelf dumpTransformedEvents:transformedPayloads ToDestination:destinationId];
                                [strongSelf->dbpersistenceManager deleteEvents:_dbMessage.messageIds withDestinationId:destinationId];
                            }
                            //                            We would be deleting the events from the events_to_transformation table only on 200 because we will not be getting any events in the case of 400/500
                            //                            May be we will pick this up in v1
                            //                            else {
                            //                                NSMutableArray* successfullyTransformedEventIds = [[NSMutableArray alloc] init];
                            //                                for(NSDictionary* transformedPayload in transformedPayloads) {
                            //                                    [successfullyTransformedEventIds addObject:transformedPayload[@"orderNo"]];
                            //                                }
                            //                                [strongSelf->dbpersistenceManager deleteEvents:successfullyTransformedEventIds withTransformationId:transformationId];
                            //                            }
                        }
                        NSArray<NSString*>* eventsWithDestinationsMapping = [strongSelf->dbpersistenceManager getEventIdsWithDestinationMapping:_dbMessage.messageIds];
                        NSMutableArray<NSString*>* processedEvents = [_dbMessage.messageIds mutableCopy];
                        [processedEvents removeObjectsInArray:eventsWithDestinationsMapping];
                        [strongSelf->dbpersistenceManager updateEventsWithIds:processedEvents withStatus:DEVICEMODEPROCESSINGDONE];
                        [strongSelf->dbpersistenceManager clearProcessedEventsFromDB];
                    }
                }
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSEventRepository: initiateTransformationProcessor: SleepCount: %d", deviceModeSleepCount]];
            }while([strongSelf->dbpersistenceManager getDBRecordCountForMode:DEVICEMODE] > 0);
        }
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSEventRepository: initiateTransformationProcessor: deviceModeSleepCount: %d", deviceModeSleepCount]];
        deviceModeSleepCount += 1;
    });
}

- (void) __replayMessageQueue {
    @synchronized (self->eventReplayMessage) {
        [RSLogger logDebug:@"replaying old messages with factory"];
        if (self->eventReplayMessage.count > 0) {
            NSArray* rowIds = [[self->eventReplayMessage allKeys] sortedArrayUsingSelector:@selector(compare:)];
            for (NSNumber *rowId in rowIds) {
                [self makeFactoryDump:eventReplayMessage[rowId] withRowId:rowId andFromHistory:YES];
            }
        }
        [self->eventReplayMessage removeAllObjects];
    }
}

- (void) __initiateProcessor {
    __weak RSEventRepository *weakSelf = self;
    dispatch_async(flush_processor_queue, ^{
        RSEventRepository *strongSelf = weakSelf;
        [RSLogger logDebug:@"processor started"];
        int errResp = 0;
        int sleepCount = 0;
        
        while (YES) {
            [strongSelf->lock lock];
            [strongSelf clearOldEvents];
            [RSLogger logDebug:@"RSEventRepository: initiateProcessor: Fetching events to flush to server in processor"];
            RSDBMessage* _dbMessage = [strongSelf->dbpersistenceManager fetchEventsFromDB:(strongSelf->config.flushQueueSize) ForMode:CLOUDMODE];
            if ((_dbMessage.messages.count >= strongSelf->config.flushQueueSize) || (_dbMessage.messages.count > 0 && (sleepCount >= strongSelf->config.sleepTimeout))) {
                errResp = [strongSelf flushEventsToServer:_dbMessage];
                if (errResp == 0) {
                    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSEventRepository: initiateProcessor: Updating status as CLOUDMODEPROCESSING DONE for events (%@)",[RSUtils getCSVString:_dbMessage.messageIds]]];
                    [strongSelf->dbpersistenceManager updateEventsWithIds:_dbMessage.messageIds withStatus:CLOUDMODEPROCESSINGDONE];
                    [strongSelf->dbpersistenceManager clearProcessedEventsFromDB];
                    sleepCount = 0;
                }
            }
            [strongSelf->lock unlock];
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSEventRepository: initiateProcessor: SleepCount: %d", sleepCount]];
            sleepCount += 1;
            if (errResp == WRONGWRITEKEY) {
                [RSLogger logDebug:@"RSEventRepository: initiateProcessor: Wrong WriteKey. Aborting."];
                break;
            } else if (errResp == NETWORKERROR) {
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSEventRepository: initiateProcessor: Retrying in: %d s", abs(sleepCount - strongSelf->config.sleepTimeout)]];
                usleep(abs(sleepCount - strongSelf->config.sleepTimeout) * 1000000);
            } else {
                usleep(1000000);
            }
        }
    });
}

- (void)clearOldEvents {
    [self ->dbpersistenceManager clearProcessedEventsFromDB];
    int recordCount = [self->dbpersistenceManager getDBRecordCountForMode:CLOUDMODE|DEVICEMODE];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"DBRecordCount %d", recordCount]];
    
    if (recordCount > self->config.dbCountThreshold) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Old DBRecordCount %d", (recordCount - self->config.dbCountThreshold)]];
        RSDBMessage *dbMessage = [self->dbpersistenceManager fetchEventsFromDB:(recordCount - self->config.dbCountThreshold) ForMode: DEVICEMODE | CLOUDMODE];
        [self->dbpersistenceManager clearEventsFromDB:dbMessage.messageIds];
    }
}

- (void) setUpFlush {
    lock = [NSLock new];
    queue = dispatch_queue_create("com.rudder.flushQueue", NULL);
    source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, queue);
    __weak RSEventRepository *weakSelf = self;
    dispatch_source_set_event_handler(source, ^{
        RSEventRepository* strongSelf = weakSelf;
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Flush: coalesce %lu calls into a single flush call", dispatch_source_get_data(strongSelf->source)]];
        [strongSelf flushSync];
    });
    dispatch_resume(source);
}

-(void) flush {
    if (self->areFactoriesInitialized) {
        for (NSString *key in [self->integrationOperationMap allKeys]) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"flushing native SDK for %@", key]];
            id<RSIntegration> integration = [self->integrationOperationMap objectForKey:key];
            if (integration != nil) {
                [integration flush];
            }
        }
    } else {
        [RSLogger logDebug:@"factories are not initialized. ignoring flush call"];
    }
    dispatch_source_merge_data(source, 1);
}

- (void)flushSync {
    [lock lock];
    [self clearOldEvents];
    [RSLogger logDebug:@"Fetching events to flush to server in flush"];
    RSDBMessage* _dbMessage = [self->dbpersistenceManager fetchAllEventsFromDBForMode:CLOUDMODE];
    int numberOfBatches = [RSUtils getNumberOfBatches:_dbMessage withFlushQueueSize:self->config.flushQueueSize];
    int errResp = -1;
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Flush: %d batches of events to be flushed", numberOfBatches]];
    BOOL lastBatchFailed = NO;
    for(int i=1; i<= numberOfBatches; i++) {
        lastBatchFailed = YES;
        int retries = 3;
        while(retries-- > 0) {
            NSMutableArray<NSString *>* messages = [RSUtils getBatch:_dbMessage.messages withQueueSize:self->config.flushQueueSize];
            NSMutableArray<NSString *>* messageIds = [RSUtils getBatch:_dbMessage.messageIds withQueueSize:self->config.flushQueueSize];
            RSDBMessage *batchDBMessage = [[RSDBMessage alloc] init];
            batchDBMessage.messageIds = messageIds;
            batchDBMessage.messages = messages;
            errResp = [self flushEventsToServer:batchDBMessage];
            if( errResp == 0){
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Flush: Successfully sent batch %d/%d", i, numberOfBatches]];
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Flush: Clearing events of batch %d from DB", i]];
                [self -> dbpersistenceManager updateEventsWithIds:batchDBMessage.messageIds withStatus:CLOUDMODEPROCESSINGDONE];
                [self->dbpersistenceManager clearProcessedEventsFromDB];
                [_dbMessage.messages removeObjectsInArray:messages];
                [_dbMessage.messageIds removeObjectsInArray:messageIds];
                lastBatchFailed = NO;
                break;
            }
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Flush: Failed to send %d/%d, retrying again, %d retries left", i, numberOfBatches, retries]];
        }
        if(lastBatchFailed) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Flush: Failed to send %d/%d batch after 3 retries, dropping the remaining batches as well", i, numberOfBatches]];
            break;
        }
    }
    [lock unlock];
}

- (int)flushEventsToServer:(RSDBMessage *)dbMessage {
    int errResp = -1;
    NSString* payload = [self __getPayloadFromMessages:dbMessage];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Payload: %@", payload]];
    [RSLogger logInfo:[[NSString alloc] initWithFormat:@"EventCount: %lu", (unsigned long)dbMessage.messageIds.count]];
    if (payload != nil) {
        errResp = [[self __flushEvents:payload toEndpoint:BATCH_ENDPOINT][STATUS] intValue];
    }
    return errResp;
}

- (NSString*) __getPayloadFromMessages: (RSDBMessage*)dbMessage{
    NSMutableArray<NSString *>* messages = dbMessage.messages;
    NSMutableArray<NSString *>* messageIds = dbMessage.messageIds;
    NSMutableArray<NSString *> *batchMessageIds = [[NSMutableArray alloc] init];
    NSString* sentAt = [RSUtils getTimestamp];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RecordCount: %lu", (unsigned long)messages.count]];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"sentAtTimeStamp: %@", sentAt]];
    
    NSMutableString* json = [[NSMutableString alloc] init];
    
    [json appendString:@"{"];
    [json appendFormat:@"\"sentAt\":\"%@\",", sentAt];
    [json appendString:@"\"batch\":["];
    unsigned int totalBatchSize = [RSUtils getUTF8Length:json] + 2; // we add 2 characters at the end
    for (int index = 0; index < messages.count; index++) {
        NSMutableString* message = [[NSMutableString alloc] initWithString:messages[index]];
        long length = message.length;
        message = [[NSMutableString alloc] initWithString:[message substringWithRange:NSMakeRange(0, (length-1))]];
        [message appendFormat:@",\"sentAt\":\"%@\"},", sentAt];
        // add message size to batch size
        totalBatchSize += [RSUtils getUTF8Length:message];
        // check totalBatchSize
        if(totalBatchSize > MAX_BATCH_SIZE) {
            [RSLogger logDebug:[NSString stringWithFormat:@"MAX_BATCH_SIZE reached at index: %i | Total: %i",index, totalBatchSize]];
            break;
        }
        [json appendString:message];
        [batchMessageIds addObject:messageIds[index]];
    }
    if([json characterAtIndex:[json length]-1] == ',') {
        // remove trailing ','
        [json deleteCharactersInRange:NSMakeRange([json length]-1, 1)];
    }
    [json appendString:@"]}"];
    // retain all events that are part of the current event
    dbMessage.messageIds = batchMessageIds;
    
    return [json copy];
}

-(NSDictionary<NSString*, NSString*>*) __flushEvents: (NSString*) payload toEndpoint:(ENDPOINT) endpoint {
    NSMutableDictionary<NSString*, NSString*>* responseDict = [[NSMutableDictionary alloc] init];
    if (self->authToken == nil || [self->authToken isEqual:@""]) {
        [RSLogger logError:@"WriteKey was not correct. Aborting flush to server"];
        responseDict[STATUS] = [[NSString alloc] initWithFormat:@"%d", WRONGWRITEKEY];
        return responseDict;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    int __block respStatus = NETWORKSUCCESS;
    NSString *requestEndPoint = nil;
    switch(endpoint) {
        case TRANSFORM_ENDPOINT:
            requestEndPoint = [self->config.dataPlaneUrl stringByAppendingString:@"/transform"];
            break;
        default:
            requestEndPoint = [self->config.dataPlaneUrl stringByAppendingString:@"/batch"];
    }
    
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"endPointToFlush %@", requestEndPoint]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:requestEndPoint]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:@"Application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:[[NSString alloc] initWithFormat:@"Basic %@", self->authToken] forHTTPHeaderField:@"Authorization"];
    dispatch_sync([RSContext getQueue], ^{
        [urlRequest addValue:self->anonymousIdToken forHTTPHeaderField:@"AnonymousId"];
    });
    NSData *httpBody = [payload dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:httpBody];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"statusCode %ld", (long)httpResponse.statusCode]];
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        responseDict[RESPONSE] = responseString;
        if (httpResponse.statusCode == 200) {
            respStatus = NETWORKSUCCESS;
            responseDict[STATUS] = [[NSString alloc] initWithFormat:@"%d", NETWORKSUCCESS];
        } else {
            if (
                ![responseString isEqualToString:@""] && // non-empty response
                [[responseString lowercaseString] rangeOfString:@"invalid write key"].location != NSNotFound
                ) {
                    respStatus = WRONGWRITEKEY;
                    responseDict[STATUS] = [[NSString alloc] initWithFormat:@"%d", WRONGWRITEKEY];
                } else {
                    respStatus = NETWORKERROR;
                    responseDict[STATUS] = [[NSString alloc] initWithFormat:@"%d", NETWORKERROR];
                }
            [RSLogger logError:[[NSString alloc] initWithFormat:@"ServerError: %@", responseString]];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    @synchronized (UPLOAD_LOCK) {
        [dataTask resume];
    }
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
#if !__has_feature(objc_arc)
    dispatch_release(semaphore);
#endif
    
    return responseDict;
}

- (NSDictionary<NSString*, NSString*>*)flushEventsToTransformationServer:(RSDBMessage *)dbMessage {
    NSDictionary<NSString*, NSString*>* response = nil;
    NSDictionary<NSString*, NSArray<NSString*>*>* eventToDestinationMapping = [self->dbpersistenceManager getDestinationMappingofEvents:dbMessage.messageIds];
    NSString* payload = [self __getPayloadForTransformation:dbMessage withEventToTransformationMapping:eventToDestinationMapping];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Payload: %@", payload]];
    [RSLogger logInfo:[[NSString alloc] initWithFormat:@"EventCount: %lu", (unsigned long)dbMessage.messageIds.count]];
    if (payload != nil) {
        response = [self __flushEvents:payload toEndpoint:TRANSFORM_ENDPOINT];
    }
    return response;
}

-(NSString*) __getPayloadForTransformation:(RSDBMessage *)dbMessage withEventToTransformationMapping:(NSDictionary<NSString*, NSArray<NSString*>*>*) eventsToDestinationsMapping {
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
        [message appendFormat:@"\"event\": %@,", messages[index]];
        [message appendFormat:@"\"destinationIds\" : [%@]", [RSUtils getJSONCSVString: eventsToDestinationsMapping[messageIds[index]]]];
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

- (void) dump:(RSMessage *)message {
    dispatch_sync([RSContext getQueue], ^{
        if (message == nil || !self->isSDKEnabled) {
            return;
        }
    });
    if([message.integrations count]==0){
        if(RSClient.getDefaultOptions!=nil &&
           RSClient.getDefaultOptions.integrations!=nil &&
           [RSClient.getDefaultOptions.integrations count]!=0){
            message.integrations = RSClient.getDefaultOptions.integrations;
        }
        else{
            message.integrations = @{@"All": @YES};
        }
    }
    // If `All` is absent in the integrations object we will set it to true for making All is true by default
    if(message.integrations[@"All"]==nil)
    {
        NSMutableDictionary<NSString *, NSObject *>* mutableIntegrations = [message.integrations mutableCopy];
        [mutableIntegrations setObject:@YES forKey:@"All"];
        message.integrations = mutableIntegrations;
        
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[message dict] options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"dump: %@", jsonString]];
    
    unsigned int messageSize = [RSUtils getUTF8Length:jsonString];
    if (messageSize > MAX_EVENT_SIZE) {
        [RSLogger logError:[NSString stringWithFormat:@"dump: Event size exceeds the maximum permitted event size(%iu)", MAX_EVENT_SIZE]];
        return;
    }
    
    NSNumber* rowId = [self->dbpersistenceManager saveEvent:jsonString];
    [self makeFactoryDump: message withRowId: rowId andFromHistory:NO];
    
}

- (void) makeFactoryDump:(RSMessage *)message withRowId:(NSNumber*) rowId andFromHistory:(BOOL) fromHistory {
    if (self->areFactoriesInitialized || fromHistory) {
        [RSLogger logDebug:@"dumping message to native sdk factories"];
        NSDictionary<NSString*, NSObject*>*  integrationOptions = message.integrations;
        // If All is set to true we will dump to all the integrations which are not set to false
        for (NSString *key in [self->integrationOperationMap allKeys]) {
            
            if(([(NSNumber*)integrationOptions[@"All"] boolValue] && (integrationOptions[key]==nil ||[(NSNumber*)integrationOptions[key] boolValue])) || ([(NSNumber*)integrationOptions[key] boolValue]))
            {
                id<RSIntegration> integration = [self->integrationOperationMap objectForKey:key];
                if (integration != nil)
                {
                    if([self->eventFilteringPlugin isEventAllowed:key withMessage:message]) {
                        if(destinationsWithTransformationsEnabled[key] == nil) {
                            
                            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"dumping for %@", key]];
                            [integration dump:message];
                            
                        }
                        else {
                            [RSLogger logVerbose:[[NSString alloc] initWithFormat:@"Destination %@ needs transformation, hence saving it to the transformation table", key]];
                            [dbpersistenceManager saveEvent:rowId toDestinationId:destinationsWithTransformationsEnabled[key]];
                        }
                    }
                }
            }
        }
    } else {
        @synchronized (self->eventReplayMessage) {
            [RSLogger logDebug:@"factories are not initialized. dumping to replay queue"];
            self->eventReplayMessage[rowId] = message;
        }
    }
}

-(void) dumpTransformedEvents:(NSArray*) transformedPayloads ToDestination:(NSString*) destinationId {
    for (NSDictionary* transformedPayload in transformedPayloads) {
        RSMessage* transformedMessage = [[RSMessage alloc] initWithDict:transformedPayload[@"event"]];
        NSArray<NSString*>* destinationNames = [destinationsWithTransformationsEnabled allKeysForObject:destinationId];
        if(destinationNames.count >0) {
            NSString* destinationName = destinationNames[0];
            id<RSIntegration> integration = [self->integrationOperationMap objectForKey:destinationName];
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"dumping the transformed event %@ for %@", transformedMessage.event, destinationName]];
            [integration dump:transformedMessage];
        }
    }
}




-(void) reset {
    if (self->areFactoriesInitialized) {
        for (NSString *key in [self->integrationOperationMap allKeys]) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"resetting native SDK for %@", key]];
            id<RSIntegration> integration = [self->integrationOperationMap objectForKey:key];
            if (integration != nil) {
                [integration reset];
            }
        }
    } else {
        [RSLogger logDebug:@"factories are not initialized. ignoring reset call"];
    }
}


- (void) __prepareIntegrations {
    RSServerConfigSource *serverConfig = [self->configManager getConfig];
    if (serverConfig != nil) {
        self->integrations = [[NSMutableDictionary alloc] init];
        for (RSServerDestination *destination in serverConfig.destinations) {
            if ([self->integrations objectForKey:destination.destinationDefinition.definitionName] == nil) {
                [self->integrations setObject:[[NSNumber alloc] initWithBool:destination.isDestinationEnabled] forKey:destination.destinationDefinition.definitionName];
            }
        }
    }
}

- (RSConfig *)getConfig {
    return self->config;
}

- (BOOL) getOptStatus {
    return [preferenceManager getOptStatus];
}

- (void) saveOptStatus: (BOOL) optStatus {
    [preferenceManager saveOptStatus:optStatus];
    [self updateOptStatusTime:optStatus];
}

- (void) updateOptStatusTime: (BOOL) optStatus {
    if (optStatus) {
        [preferenceManager updateOptOutTime:[RSUtils getTimeStampLong]];
    } else {
        [preferenceManager updateOptInTime:[RSUtils getTimeStampLong]];
    }
}

- (void) __checkApplicationUpdateStatus {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
#if !TARGET_OS_WATCH
    for (NSString *name in @[ UIApplicationDidEnterBackgroundNotification,
                              UIApplicationDidFinishLaunchingNotification,
                              UIApplicationWillEnterForegroundNotification,
                              UIApplicationWillTerminateNotification,
                              UIApplicationWillResignActiveNotification,
                              UIApplicationDidBecomeActiveNotification ]) {
        [nc addObserver:self selector:@selector(handleAppStateNotification:) name:name object:UIApplication.sharedApplication];
    }
#else
    for (NSString *name in @[ WKApplicationDidEnterBackgroundNotification,
                              WKApplicationDidFinishLaunchingNotification,
                              WKApplicationWillEnterForegroundNotification,
                              WKApplicationWillResignActiveNotification,
                              WKApplicationDidBecomeActiveNotification ]) {
        [nc addObserver:self selector:@selector(handleAppStateNotification:) name:name object:nil];
    }
#endif
}

- (void) handleAppStateNotification: (NSNotification*) notification {
#if !TARGET_OS_WATCH
    if ([notification.name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
        [self _applicationDidFinishLaunchingWithOptions:notification.userInfo];
    } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self _applicationWillEnterForeground];
    } else if ([notification.name isEqualToString: UIApplicationDidEnterBackgroundNotification]) {
        [self _applicationDidEnterBackground];
    }
#else
    if ([notification.name isEqualToString:WKApplicationDidFinishLaunchingNotification]) {
        [self _applicationDidFinishLaunchingWithOptions:notification.userInfo];
    } else if ([notification.name isEqualToString: WKApplicationDidBecomeActiveNotification]) {
        [self _applicationWillEnterForeground];
    } else if ([notification.name isEqualToString: WKApplicationWillResignActiveNotification]) {
        [self _applicationDidEnterBackground];
    }
#endif
}

- (void)_applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (!self->config.trackLifecycleEvents) {
        return;
    }
    NSString *previousVersion = [preferenceManager getBuildVersionCode];
    NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    
    if (!previousVersion) {
        [[RSClient sharedInstance] track:@"Application Installed" properties:@{
            @"version": currentVersion
        }];
        [preferenceManager saveBuildVersionCode:currentVersion];
    } else if (![currentVersion isEqualToString:previousVersion]) {
        [[RSClient sharedInstance] track:@"Application Updated" properties:@{
            @"previous_version" : previousVersion ?: @"",
            @"version": currentVersion
        }];
        [preferenceManager saveBuildVersionCode:currentVersion];
    }
    
    NSMutableDictionary *applicationOpenedProperties = [[NSMutableDictionary alloc] init];
    [applicationOpenedProperties setObject:@NO forKey:@"from_background"];
    if (currentVersion != nil) {
        [applicationOpenedProperties setObject:currentVersion forKey:@"version"];
    }
#if !TARGET_OS_WATCH
    NSString *referring_application = [[NSString alloc] initWithFormat:@"%@", launchOptions[UIApplicationLaunchOptionsSourceApplicationKey] ?: @""];
    if ([referring_application length]) {
        [applicationOpenedProperties setObject:referring_application forKey:@"referring_application"];
    }
    NSString *url = [[NSString alloc] initWithFormat:@"%@", launchOptions[UIApplicationLaunchOptionsURLKey] ?: @""];
    if ([url length]) {
        [applicationOpenedProperties setObject:url forKey:@"url"];
    }
#endif
    [[RSClient sharedInstance] track:@"Application Opened" properties:applicationOpenedProperties];
    
}

- (void)_applicationWillEnterForeground {
#if TARGET_OS_WATCH
    if(self->firstForeGround) {
        self->firstForeGround = NO;
        return;
    }
#endif
    
    if(config.enableBackgroundMode) {
#if !TARGET_OS_WATCH
        [self registerBackGroundTask];
#else
        [self askForAssertionWithSemaphore];
#endif
    }
    
    if (!self->config.trackLifecycleEvents) {
        return;
    }
    
    [[RSClient sharedInstance] track:@"Application Opened" properties:@{
        @"from_background" : @YES
    }];
}

- (void)_applicationDidEnterBackground {
    if (!self->config.trackLifecycleEvents) {
        return;
    }
    [[RSClient sharedInstance] track:@"Application Backgrounded"];
}

- (void) __prepareScreenRecorder {
#if TARGET_OS_WATCH
    [WKInterfaceController rudder_swizzleView];
#else
    [UIViewController rudder_swizzleView];
#endif
}

#if !TARGET_OS_WATCH
- (void) registerBackGroundTask {
    if(backgroundTask != UIBackgroundTaskInvalid) {
        [self endBackGroundTask];
    }
    [RSLogger logDebug:@"EventRepository: registerBackGroundTask: Registering for Background Mode"];
    __weak RSEventRepository *weakSelf = self;
    backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        RSEventRepository *strongSelf = weakSelf;
        [strongSelf endBackGroundTask];
    }];
}

- (void) endBackGroundTask {
    [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
    backgroundTask = UIBackgroundTaskInvalid;
}

#else

- (void) askForAssertionWithSemaphore {
    if(self->semaphore == nil) {
        self->semaphore = dispatch_semaphore_create(0);
    } else if (!self->isSemaphoreReleased) {
        [self releaseAssertionWithSemaphore];
    }
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    [processInfo performExpiringActivityWithReason:@"backgroundRunTime" usingBlock:^(BOOL expired) {
        if (expired) {
            [self releaseAssertionWithSemaphore];
            self->isSemaphoreReleased = YES;
        } else {
            [RSLogger logDebug:@"EventRepository: askForAssertionWithSemaphore: Asking Semaphore for Assertion to wait forever for backgroundMode"];
            self->isSemaphoreReleased = NO;
            dispatch_semaphore_wait(self->semaphore, DISPATCH_TIME_FOREVER);
        }
    }];
}

- (void) releaseAssertionWithSemaphore {
    [RSLogger logDebug:@"EventRepository: releaseAssertionWithSemaphore: Releasing Assertion on Semaphore for backgroundMode"];
    dispatch_semaphore_signal(self->semaphore);
}

#endif

@end
