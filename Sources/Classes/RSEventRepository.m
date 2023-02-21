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
#import "RSConsentFilterHandler.h"

#import "WKInterfaceController+RSScreen.h"
#import "UIViewController+RSScreen.h"

static RSEventRepository* _instance;

@implementation RSEventRepository
typedef enum {
    NETWORKERROR =1,
    NETWORKSUCCESS =0,
    WRONGWRITEKEY =2
} NETWORKSTATE;

+ (instancetype)initiate:(NSString *)writeKey config:(RSConfig *)config client:(RSClient *)client {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init:writeKey config:config client:client];
        });
    }
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
- (instancetype)init:(NSString*)_writeKey config:(RSConfig*)_config client:(RSClient *)_client {
    self = [super init];
    if (self) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: writeKey: %@", _writeKey]];
        
        self->firstForeGround = YES;
        self->areFactoriesInitialized = NO;
        self->isSDKEnabled = YES;
        self->isSDKInitialized = NO;
        self->client = _client;
        
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
        self->eventReplayMessage = [[NSMutableArray alloc] init];
        
        [self setAnonymousIdToken];
        
        [RSLogger logDebug:@"EventRepository: initiating dbPersistentManager"];
        dbpersistenceManager = [[RSDBPersistentManager alloc] init];
        
        [RSLogger logDebug:@"EventRepository: initiating server config manager"];
        configManager = [[RSServerConfigManager alloc] init:writeKey rudderConfig:config];
        
        [RSLogger logDebug:@"EventRepository: initiating preferenceManager"];
        self->preferenceManager = [RSPreferenceManager getInstance];
        [self->preferenceManager performMigration];
        
        [RSLogger logDebug:@"EventRepository: initiating processor and factories"];
        [self __initiateSDK];
        
        [RSLogger logDebug:@"EventRepository: Initiating User Session Manager"];
        self->userSession = [RSUserSession initiate:self->config.sessionInActivityTimeOut with: self->preferenceManager];
        
        // clear session if automatic session tracking was enabled previously but disabled presently or vice versa.
        BOOL previousAutoTrackingStatus = [self->preferenceManager getAutoTrackingStatus];
        if(previousAutoTrackingStatus && previousAutoTrackingStatus != config.automaticSessionTracking) {
            [RSLogger logDebug:@"EventRepository: Automatic Session Tracking status has been updated since last launch, hence clearing the session"];
            [self->userSession clearSession];
        }
        [self->preferenceManager saveAutoTrackingStatus:config.automaticSessionTracking];
        
        if(self->config.trackLifecycleEvents && self->config.automaticSessionTracking) {
            [RSLogger logDebug:@"EventRepository: Starting Automatic Sessions"];
            [self->userSession startSessionIfExpired];
        }
        
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
                    strongSelf->dataPlaneUrl = [RSUtils getDataPlaneUrlFrom:serverConfig andRSConfig:self->config];
                    if (strongSelf->dataPlaneUrl == nil) {
                        [RSLogger logError:DATA_PLANE_URL_ERROR];
                        return;
                    }
                    [RSLogger logDebug:@"EventRepository: initiating processor"];
                    [strongSelf __initiateProcessor];
                    
                    // initiate consent filter handler
                    if (strongSelf->config.consentFilter != nil) {
                        [RSLogger logDebug:@"EventRepository: initiating consentFilter"];
                        strongSelf->consentFilterHandler = [RSConsentFilterHandler initiate:strongSelf->config.consentFilter withServerConfig:serverConfig];
                    }
                    
                    // initiate the native SDK factories if destinations are present
                    [strongSelf __initiateNativeFactories:serverConfig];
                    
                    // initiate custom factories
                    [strongSelf __initiateCustomFactories];
                    strongSelf->areFactoriesInitialized = YES;
                    
                    [strongSelf __replayMessageQueue];
                    
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

- (void)__initiateNativeFactories:(RSServerConfigSource *)serverConfig {
    // initialize integrationOperationMap
    integrationOperationMap = [[NSMutableDictionary alloc] init];
    
    if (serverConfig.destinations != nil && serverConfig.destinations.count > 0) {
        NSArray <RSServerDestination *> *consentedDestinations = consentFilterHandler != nil ? [consentFilterHandler filterDestinationList:serverConfig.destinations] : serverConfig.destinations;
        [RSLogger logDebug:@"EventRepository: initiating factories"];
        [self __initiateFactories:consentedDestinations];
        [RSLogger logDebug:@"EventRepository: initiating event filtering plugin for device mode destinations"];
        eventFilteringPlugin = [[RSEventFilteringPlugin alloc] init:consentedDestinations];
    } else {
        eventFilteringPlugin = [[RSEventFilteringPlugin alloc] init];
        [RSLogger logDebug:@"EventRepository: no device mode present"];
    }
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
                        id<RSIntegration> nativeOp = [factory initiate:destinationConfig client:client rudderConfig:config];
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
        id<RSIntegration> nativeOp = [factory initiate:@{} client:client rudderConfig:self->config];
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Initiating custom factory %@", factory.key]];
        [self->integrationOperationMap setValue:nativeOp forKey:factory.key];
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Initiated custom SDK factory %@", factory.key]];
        // put custom sdk initalization callback
    }
}

- (void) __replayMessageQueue {
    @synchronized (self->eventReplayMessage) {
        [RSLogger logDebug:@"replaying old messages with factory"];
        if (self->eventReplayMessage.count > 0) {
            for (RSMessage *msg in self->eventReplayMessage) {
                [self makeFactoryDump:msg];
            }
        }
        [self->eventReplayMessage removeAllObjects];
    }
}

- (void) __initiateProcessor {
    __weak RSEventRepository *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        RSEventRepository *strongSelf = weakSelf;
        [RSLogger logDebug:@"processor started"];
        int errResp = 0;
        int sleepCount = 0;
        
        while (YES) {
            [strongSelf->lock lock];
            [strongSelf clearOldEvents];
            [RSLogger logDebug:@"Fetching events to flush to server in processor"];
            RSDBMessage* _dbMessage = [strongSelf->dbpersistenceManager fetchEventsFromDB:(strongSelf->config.flushQueueSize)];
            if (_dbMessage.messages.count > 0 && (sleepCount >= strongSelf->config.sleepTimeout)) {
                errResp = [strongSelf flushEventsToServer:_dbMessage];
                if (errResp == 0) {
                    [RSLogger logDebug:@"clearing events from DB"];
                    [strongSelf->dbpersistenceManager clearEventsFromDB:_dbMessage.messageIds];
                    sleepCount = 0;
                }
            }
            [strongSelf->lock unlock];
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"SleepCount: %d", sleepCount]];
            sleepCount += 1;
            if (errResp == WRONGWRITEKEY) {
                [RSLogger logDebug:@"Wrong WriteKey. Aborting."];
                break;
            } else if (errResp == NETWORKERROR) {
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Retrying in: %d s", abs(sleepCount - strongSelf->config.sleepTimeout)]];
                usleep(abs(sleepCount - strongSelf->config.sleepTimeout) * 1000000);
            } else {
                usleep(1000000);
            }
        }
    });
}

- (void)clearOldEvents {
    int recordCount = [self->dbpersistenceManager getDBRecordCount];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"DBRecordCount %d", recordCount]];
    
    if (recordCount > self->config.dbCountThreshold) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Old DBRecordCount %d", (recordCount - self->config.dbCountThreshold)]];
        RSDBMessage *dbMessage = [self->dbpersistenceManager fetchEventsFromDB:(recordCount - self->config.dbCountThreshold)];
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
    if (self->dataPlaneUrl == nil) {
        [RSLogger logError:DATA_PLANE_URL_FLUSH_ERROR];
        return;
    }
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
    if (self->dataPlaneUrl == nil) {
        [RSLogger logError:DATA_PLANE_URL_FLUSH_ERROR];
        return;
    }
    [lock lock];
    [self clearOldEvents];
    [RSLogger logDebug:@"Fetching events to flush to server in flush"];
    RSDBMessage* _dbMessage = [self->dbpersistenceManager fetchAllEventsFromDB];
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
                [self -> dbpersistenceManager clearEventsFromDB: batchDBMessage.messageIds];
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
        errResp = [self __flushEventsToServer:payload];
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
    int index;
    for (index = 0; index < messages.count; index++) {
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

- (int) __flushEventsToServer: (NSString*) payload {
    if (self->authToken == nil || [self->authToken isEqual:@""]) {
        [RSLogger logError:@"WriteKey was not correct. Aborting flush to server"];
        return WRONGWRITEKEY;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    int __block respStatus = NETWORKSUCCESS;
    NSString *dataPlaneEndPoint = [self->dataPlaneUrl stringByAppendingString:@"v1/batch"];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"endPointToFlush %@", dataPlaneEndPoint]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:dataPlaneEndPoint]];
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
        
        if (httpResponse.statusCode == 200) {
            respStatus = NETWORKSUCCESS;
        } else {
            NSString *errorResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (
                ![errorResponse isEqualToString:@""] && // non-empty response
                [[errorResponse lowercaseString] rangeOfString:@"invalid write key"].location != NSNotFound
                ) {
                    respStatus = WRONGWRITEKEY;
                } else {
                    respStatus = NETWORKERROR;
                }
            [RSLogger logError:[[NSString alloc] initWithFormat:@"ServerError: %@", errorResponse]];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
#if !__has_feature(objc_arc)
    dispatch_release(semaphore);
#endif
    
    return respStatus;
}

- (void) dump:(RSMessage *)message {
    dispatch_sync([RSContext getQueue], ^{
        if (message == nil || !self->isSDKEnabled) {
            return;
        }
    });
    [self applyIntegrations:message withDefaultOption:RSClient.getDefaultOptions];
    message = [self applyConsents:message];
    [self applySession:message withUserSession:userSession andRudderConfig:config];
    
    [self makeFactoryDump: message];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[message dict] options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"dump: %@", jsonString]];
    
    unsigned int messageSize = [RSUtils getUTF8Length:jsonString];
    if (messageSize > MAX_EVENT_SIZE) {
        [RSLogger logError:[NSString stringWithFormat:@"dump: Event size exceeds the maximum permitted event size(%iu)", MAX_EVENT_SIZE]];
        return;
    }
    
    [self->dbpersistenceManager saveEvent:jsonString];
}

- (void)applyIntegrations:(RSMessage *)message withDefaultOption:(RSOption *)defaultOption {
    if ([message.integrations count] == 0) {
        if(defaultOption != nil && defaultOption.integrations != nil && [defaultOption.integrations count] != 0) {
            message.integrations = defaultOption.integrations;
        }
        else{
            message.integrations = @{@"All": @YES};
        }
    }
    
    // If `All` is absent in the integrations object we will set it to true for making All is true by default
    if (message.integrations[@"All"] == nil) {
        NSMutableDictionary<NSString *, NSObject *>* mutableIntegrations = [message.integrations mutableCopy];
        [mutableIntegrations setObject:@YES forKey:@"All"];
        message.integrations = mutableIntegrations;
    }
}

- (RSMessage *)applyConsents:(RSMessage *)message {
    if (consentFilterHandler != nil) {
        return [consentFilterHandler applyConsents:message];
    }
    return message;
}

- (void)applySession:(RSMessage *)message withUserSession:(RSUserSession *)_userSession andRudderConfig:(RSConfig *)rudderConfig {
    if([_userSession getSessionId] != nil) {
        [message setSessionData: _userSession];
    }
    if(rudderConfig.trackLifecycleEvents && rudderConfig.automaticSessionTracking) {
        [_userSession updateLastEventTimeStamp];
    }
}

- (void) makeFactoryDump:(RSMessage *)message {
    if (self->areFactoriesInitialized) {
        [RSLogger logDebug:@"dumping message to native sdk factories"];
        NSDictionary<NSString*, NSObject*>*  integrationOptions = message.integrations;
        // If All is set to true we will dump to all the integrations which are not set to false
        if([(NSNumber*)integrationOptions[@"All"] boolValue])
        {
            for (NSString *key in [self->integrationOperationMap allKeys]) {
                id<RSIntegration> integration = [self->integrationOperationMap objectForKey:key];
                if (integration != nil)
                {
                    if(integrationOptions[key]==nil ||[(NSNumber*)integrationOptions[key] boolValue])
                    {
                        if([self->eventFilteringPlugin isEventAllowed:key withMessage:message])
                        {
                            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"dumping for %@", key]];
                            [integration dump:message];
                        }
                    }
                }
            }
            return;
        }
        // Since All is not set to true we will dump to all the integrations which are set to true
        for (NSString *key in [self->integrationOperationMap allKeys]) {
            id<RSIntegration> integration = [self->integrationOperationMap objectForKey:key];
            if (integration != nil) {
                if([(NSNumber*)integrationOptions[key] boolValue])
                {
                    if([self->eventFilteringPlugin isEventAllowed:key withMessage:message])
                    {
                        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"dumping for %@", key]];
                        [integration dump:message];
                    }
                }
            }
        }
    } else {
        @synchronized (self->eventReplayMessage) {
            [RSLogger logDebug:@"factories are not initialized. dumping to replay queue"];
            [self->eventReplayMessage addObject:message];
        }
    }
}

-(void) reset {
    if([self->userSession getSessionId] != nil) {
        [RSLogger logDebug: @"EventRepository: reset: Refreshing the session as the reset is triggered"];
        [self->userSession refreshSession];
    }
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
    NSString *previousVersion = [preferenceManager getVersionNumber];
    NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    
    NSString* previousBuildNumber = [preferenceManager getBuildNumber];
    NSString *currentBuildNumber = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    
    if (!previousVersion) {
        [client track:@"Application Installed" properties:@{
            @"version": currentVersion,
            @"build": currentBuildNumber
        }];
        [preferenceManager saveVersionNumber:currentVersion];
        [preferenceManager saveBuildNumber:currentBuildNumber];
    } else if (![previousVersion isEqualToString:currentVersion]) {
        [client track:@"Application Updated" properties:@{
            @"previous_version" : previousVersion ?: @"",
            @"version": currentVersion,
            @"previous_build": previousBuildNumber ?: @"",
            @"build": currentBuildNumber
        }];
        [preferenceManager saveVersionNumber:currentVersion];
        [preferenceManager saveBuildNumber:currentBuildNumber];
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
    [client track:@"Application Opened" properties:applicationOpenedProperties];
    
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
    
    // Session Tracking
    // Automatic tracking session started
    if (self->config.trackLifecycleEvents && self->config.automaticSessionTracking) {
        [RSLogger logDebug:@"EventRepository: applicationWillEnterForeground: Checking if session timeout due to inactivity and creating a new one"];
        [self->userSession startSessionIfExpired];
    }
    
    [client track:@"Application Opened" properties:@{
        @"from_background" : @YES
    }];
}

- (void)_applicationDidEnterBackground {
    if (!self->config.trackLifecycleEvents) {
        return;
    }
    [client track:@"Application Backgrounded"];
}

- (void) __prepareScreenRecorder {
#if TARGET_OS_WATCH
    [WKInterfaceController rudder_swizzleView];
#else
    [UIViewController rudder_swizzleView];
#endif
}

- (void) startSession:(long) sessionId {
    if(self->config.automaticSessionTracking) {
        [self endSession];
        [self->config setAutomaticSessionTracking:NO];
    }
    [self->userSession startSession:sessionId];
}

- (void) endSession {
    if(self->config.automaticSessionTracking) {
        [self->config setAutomaticSessionTracking:NO];
    }
    [self->userSession clearSession];
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
