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
#import "UIViewController+RSScreen.h"

static RSEventRepository* _instance;

@implementation RSEventRepository
typedef enum {
    NETWORKERROR =1,
    NETWORKSUCCESS =0,
    WRONGWRITEKEY =2
} NETWORKSTATE;

+ (instancetype)initiate:(NSString *)writeKey config:(RSConfig *) config {
    if (_instance == nil) {
        _instance = [[self alloc] init:writeKey config:config];
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
- (instancetype)init : (NSString*) _writeKey config:(RSConfig*) _config {
    self = [super init];
    if (self) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: writeKey: %@", _writeKey]];
        
        self->areFactoriesInitialized = NO;
        self->isSDKEnabled = YES;
        
        writeKey = _writeKey;
        config = _config;
        
        NSData *authData = [[[NSString alloc] initWithFormat:@"%@:", _writeKey] dataUsingEncoding:NSUTF8StringEncoding];
        authToken = [authData base64EncodedStringWithOptions:0];
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: authToken: %@", authToken]];
        
        [RSLogger logDebug:@"EventRepository: initiating element cache"];
        [RSElementCache initiate];
        
        [RSLogger logDebug:@"EventRepository: initiating eventReplayMessage queue"];
        self->eventReplayMessage = [[NSMutableArray alloc] init];
        
        NSData *anonymousIdData = [[[NSString alloc] initWithFormat:@"%@:", [RSElementCache getAnonymousId]] dataUsingEncoding:NSUTF8StringEncoding];
        anonymousIdToken = [anonymousIdData base64EncodedStringWithOptions:0];
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: anonymousIdToken: %@", anonymousIdToken]];
        
        [RSLogger logDebug:@"EventRepository: initiating dbPersistentManager"];
        dbpersistenceManager = [[RSDBPersistentManager alloc] init];
        
        [RSLogger logDebug:@"EventRepository: initiating server config manager"];
        configManager = [[RSServerConfigManager alloc] init:writeKey rudderConfig:config];
        
        [RSLogger logDebug:@"EventRepository: initiating preferenceManager"];
        self->preferenceManager = [RSPreferenceManager getInstance];
        self->isOptedOut = [preferenceManager getOptStatus];
        
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

- (void) __initiateSDK {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int retryCount = 0;
        while (self->isSDKInitialized == NO && retryCount <= 5) {
            RSServerConfigSource *serverConfig = [self->configManager getConfig];
            int receivedError =[self->configManager getError];
            if (serverConfig != nil) {
                // initiate the processor if the source is enabled
                self->isSDKEnabled = serverConfig.isSourceEnabled;
                if  (self->isSDKEnabled) {
                    [RSLogger logDebug:@"EventRepository: initiating processor"];
                    [self __initiateProcessor];
                    
                    // initialize integrationOperationMap
                    self->integrationOperationMap = [[NSMutableDictionary alloc] init];
                    
                    // initiate the native SDK factories if destinations are present
                    if (serverConfig.destinations != nil && serverConfig.destinations.count > 0) {
                        [RSLogger logDebug:@"EventRepository: initiating factories"];
                        [self __initiateFactories: serverConfig.destinations];
                    } else {
                        [RSLogger logDebug:@"EventRepository: no device mode present"];
                    }
                    
                    // initiate custom factories
                    [self __initiateCustomFactories];
                    self->areFactoriesInitialized = YES;
                    [self __replayMessageQueue];
                    
                } else {
                    [RSLogger logDebug:@"EventRepository: source is disabled in your Dashboard"];
                    [self->dbpersistenceManager flushEventsFromDB];
                }
                self->isSDKInitialized = YES;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [RSLogger logDebug:@"processor started"];
        int errResp = 0;
        int sleepCount = 0;
        
        while (YES) {
            int recordCount = [self->dbpersistenceManager getDBRecordCount];
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"DBRecordCount %d", recordCount]];
            
            if (recordCount > self->config.dbCountThreshold) {
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Old DBRecordCount %d", (recordCount - self->config.dbCountThreshold)]];
                RSDBMessage *dbMessage = [self->dbpersistenceManager fetchEventsFromDB:(recordCount - self->config.dbCountThreshold)];
                [self->dbpersistenceManager clearEventsFromDB:dbMessage.messageIds];
            }
            
            [RSLogger logDebug:@"Fetching events to flush to sever"];
            RSDBMessage *dbMessage = [self->dbpersistenceManager fetchEventsFromDB:(self->config.flushQueueSize)];
            if (dbMessage.messages.count > 0 && (sleepCount >= self->config.sleepTimeout)) {
                NSString* payload = [self __getPayloadFromMessages:dbMessage];
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Payload: %@", payload]];
                [RSLogger logInfo:[[NSString alloc] initWithFormat:@"EventCount: %lu", (unsigned long)dbMessage.messageIds.count]];
                if (payload != nil) {
                    errResp = [self __flushEventsToServer:payload];
                    if (errResp == 0) {
                        [RSLogger logDebug:@"clearing events from DB"];
                        [self->dbpersistenceManager clearEventsFromDB:dbMessage.messageIds];
                        sleepCount = 0;
                    }
                }
            }
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"SleepCount: %d", sleepCount]];
            sleepCount += 1;
            if (errResp == WRONGWRITEKEY) {
                [RSLogger logDebug:@"Wrong WriteKey. Aborting."];
                break;
            } else if (errResp == NETWORKERROR) {
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Retrying in: %d s", abs(sleepCount - self->config.sleepTimeout)]];
                usleep(abs(sleepCount - self->config.sleepTimeout) * 1000000);
            } else {
                usleep(1000000);
            }
        }
    });
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
    NSString *dataPlaneEndPoint = [self->config.dataPlaneUrl stringByAppendingString:@"/v1/batch"];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"endPointToFlush %@", dataPlaneEndPoint]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:dataPlaneEndPoint]];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:@"Application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:[[NSString alloc] initWithFormat:@"Basic %@", self->authToken] forHTTPHeaderField:@"Authorization"];
    [urlRequest addValue:self->anonymousIdToken forHTTPHeaderField:@"AnonymousId"];
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
    if (message == nil || !self->isSDKEnabled) {
        return;
    }
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
                        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"dumping for %@", key]];
                        [integration dump:message];
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
                    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"dumping for %@", key]];
                    [integration dump:message];
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
    return self -> isOptedOut;
}

- (void) saveOptStatus: (BOOL) optStatus {
    [preferenceManager saveOptStatus:optStatus];
}

- (void) __checkApplicationUpdateStatus {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    for (NSString *name in @[ UIApplicationDidEnterBackgroundNotification,
                              UIApplicationDidFinishLaunchingNotification,
                              UIApplicationWillEnterForegroundNotification,
                              UIApplicationWillTerminateNotification,
                              UIApplicationWillResignActiveNotification,
                              UIApplicationDidBecomeActiveNotification ]) {
        [nc addObserver:self selector:@selector(handleAppStateNotification:) name:name object:UIApplication.sharedApplication];
    }
}

- (void) handleAppStateNotification: (NSNotification*) notification {
    if ([notification.name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
        [self _applicationDidFinishLaunchingWithOptions:notification.userInfo];
    } else if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self _applicationWillEnterForeground];
    } else if ([notification.name isEqualToString: UIApplicationDidEnterBackgroundNotification]) {
        [self _applicationDidEnterBackground];
    }
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
    } else if (![currentVersion isEqualToString:previousVersion]) {
        [[RSClient sharedInstance] track:@"Application Updated" properties:@{
            @"previous_version" : previousVersion ?: @"",
            @"version": currentVersion
        }];
    }
    
    [[RSClient sharedInstance] track:@"Application Opened" properties:@{
        @"from_background" : @NO,
        @"version" : currentVersion ?: @"",
        @"referring_application" : [[NSString alloc] initWithFormat:@"%@", launchOptions[UIApplicationLaunchOptionsSourceApplicationKey] ?: @""],
        @"url" :  [[NSString alloc] initWithFormat:@"%@", launchOptions[UIApplicationLaunchOptionsURLKey] ?: @""] ,
    }];
    
    [preferenceManager saveBuildVersionCode:currentVersion];
}

- (void)_applicationWillEnterForeground {
    if (!self->config.trackLifecycleEvents) {
        return;
    }
    
    [[RSClient sharedInstance] track:@"Application Opened" properties:@{
        @"from_background" : @YES,
    }];
}

- (void)_applicationDidEnterBackground {
    if (!self->config.trackLifecycleEvents) {
        return;
    }
    [[RSClient sharedInstance] track:@"Application Backgrounded"];
}

- (void) __prepareScreenRecorder {
    [UIViewController rudder_swizzleView];
}


@end
