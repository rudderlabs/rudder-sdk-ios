//
//  EventRepository.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "EventRepository.h"
#import "RudderElementCache.h"
#import "Utils.h"
#import "RudderLogger.h"
#import "UIViewController+RudderScreen.h"

static EventRepository* _instance;

@implementation EventRepository

+ (instancetype)initiate:(NSString *)writeKey config:(RudderConfig *) config {
    if (_instance == nil) {
        _instance = [[self alloc] init:writeKey config:config];
    }
    
    return _instance;
}

/*
 * constructor to be called from RudderClient internally.
 * -- tasks to be performed
 * 1. persist the value of config
 * 2. initiate RudderElementCache
 * 3. initiate DBPersistentManager for SQLite operations
 * 4. initiate RudderServerConfigManager
 * 5. start processor thread
 * 6. initiate factories
 * */
- (instancetype)init : (NSString*) _writeKey config:(RudderConfig*) _config {
    self = [super init];
    if (self) {
        [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: writeKey: %@", _writeKey]];
        
        self->isFactoryInitialized = NO;
        
        writeKey = _writeKey;
        config = _config;
        
        NSData *authData = [[[NSString alloc] initWithFormat:@"%@:", _writeKey] dataUsingEncoding:NSUTF8StringEncoding];
        authToken = [authData base64EncodedStringWithOptions:0];
        [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: authToken: %@", authToken]];
        
        [RudderLogger logDebug:@"EventRepository: initiating element cache"];
        [RudderElementCache initiate];
        
        NSData *anonymousIdData = [[[NSString alloc] initWithFormat:@"%@:", [RudderElementCache getAnonymousId]] dataUsingEncoding:NSUTF8StringEncoding];
        anonymousIdToken = [anonymousIdData base64EncodedStringWithOptions:0];
        [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: anonymousIdToken: %@", anonymousIdToken]];
        
        [RudderLogger logDebug:@"EventRepository: initiating dbPersistentManager"];
        dbpersistenceManager = [[DBPersistentManager alloc] init];
        
        [RudderLogger logDebug:@"EventRepository: initiating server config manager"];
        configManager = [RudderServerConfigManager getInstance:writeKey rudderConfig:config];
        
        [RudderLogger logDebug:@"EventRepository: initiating preferenceManager"];
        self->preferenceManager = [RudderPreferenceManager getInstance];
        
        [RudderLogger logDebug:@"EventRepository: initiating processor"];
        [self __initiateProcessor];
        
        [RudderLogger logDebug:@"EventRepository: initiating factories"];
        [self __initiateFactories];
        
        if (config.trackLifecycleEvents) {
            [RudderLogger logDebug:@"EventRepository: tracking application lifecycle"];
            [self __checkApplicationUpdateStatus];
        }
        
        if (config.recordScreenViews) {
            [RudderLogger logDebug:@"EventRepository: starting automatic screen records"];
            [self __prepareScreenRecorder];
        }
        
        
        
    }
    return self;
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
        [[RudderClient sharedInstance] track:@"Application Installed" properties:@{
            @"version": currentVersion
        }];
    } else if (![currentVersion isEqualToString:previousVersion]) {
        [[RudderClient sharedInstance] track:@"Application Updated" properties:@{
            @"previous_version" : previousVersion ?: @"",
            @"version": currentVersion
        }];
    }
    
    [[RudderClient sharedInstance] track:@"Application Opened" properties:@{
        @"from_background" : @NO,
        @"version" : currentVersion ?: @"",
        @"referring_application" : launchOptions[UIApplicationLaunchOptionsSourceApplicationKey] ?: @"",
        @"url" : launchOptions[UIApplicationLaunchOptionsURLKey] ?: @"",
    }];

    [preferenceManager saveBuildVersionCode:currentVersion];
}

- (void)_applicationWillEnterForeground{
    if (!self->config.trackLifecycleEvents) {
        return;
    }
    
    [[RudderClient sharedInstance] track:@"Application Opened" properties:@{
        @"from_background" : @YES,
    }];
}

- (void)_applicationDidEnterBackground {
    if (!self->config.trackLifecycleEvents) {
        return;
    }
    [[RudderClient sharedInstance] track:@"Application Backgrounded"];
}

- (void) __prepareScreenRecorder {
    [UIViewController rudder_swizzleView];
}

- (void) __initiateFactories {
    if (self->config == nil || config.factories == nil || config.factories.count == 0) {
        [RudderLogger logInfo:@"EventRepository: No native SDK is found in the config"];
        self->isFactoryInitialized = YES;
        return;
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            RudderClient *client = [RudderClient sharedInstance];
            int retryCount = 0;
            while (self->isFactoryInitialized == NO && retryCount <= 5) {
                RudderServerConfigSource *serverConfig = [self->configManager getConfig];
                
                if (serverConfig != nil && serverConfig.destinations != nil) {
                    NSArray *destinations = serverConfig.destinations;
                    if (destinations.count == 0) {
                        [RudderLogger logInfo:@"EventRepository: No native SDK factory is found in the server config"];
                    } else {
                        NSMutableDictionary<NSString*, RudderServerDestination*> *destinationDict = [[NSMutableDictionary alloc] init];
                        for (RudderServerDestination *destination in destinations) {
                            [destinationDict setObject:destination forKey:destination.destinationDefinition.displayName];
                        }
                        NSMutableDictionary<NSString*, id<RudderIntegration>> *tempIntegrationOpDict = [[NSMutableDictionary alloc] init];
                        for (id<RudderIntegrationFactory> factory in self->config.factories) {
                            RudderServerDestination *destination = [destinationDict objectForKey:factory.key];
                            if (destination != nil && destination.isDestinationEnabled == YES) {
                                NSDictionary *destinationConfig = destination.destinationConfig;
                                if (destinationConfig != nil) {
                                    id<RudderIntegration> nativeOp = [factory initiate:destinationConfig client:client rudderConfig:self->config];
                                    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Initiating native SDK factory %@", factory.key]];
                                    [tempIntegrationOpDict setValue:nativeOp forKey:factory.key];
                                    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Initiated native SDK factory %@", factory.key]];
                                    // put native sdk initialization callback
                                }
                            }
                        }
                        self->integrationOperationMap = tempIntegrationOpDict;
                    }
                    self->isFactoryInitialized = YES;
                    @synchronized (self->eventReplayMessage) {
                        [RudderLogger logDebug:@"replaying old messages with factory"];
                        NSArray *tempMessages = [self->eventReplayMessage copy];
                        if (tempMessages.count > 0) {
                            for (RudderMessage *msg in tempMessages) {
                                [self makeFactoryDump:msg];
                            }
                        }
                        [self->eventReplayMessage removeAllObjects];
                    }
                } else {
                    retryCount += 1;
                    [RudderLogger logDebug:@"server config is null. retrying in 10s."];
                    usleep(10000000);
                }
            }
        });
    }
}

- (void)__initiateProcessor {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [RudderLogger logDebug:@"processor started"];
        
        int sleepCount = 0;
        
        while (YES) {
            int recordCount = [self->dbpersistenceManager getDBRecordCount];
            [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"DBRecordCount %d", recordCount]];
            
            if (recordCount > self->config.dbCountThreshold) {
                [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Old DBRecordCount %d", (recordCount - self->config.dbCountThreshold)]];
                RudderDBMessage *dbMessage = [self->dbpersistenceManager fetchEventsFromDB:(recordCount - self->config.dbCountThreshold)];
                [self->dbpersistenceManager clearEventsFromDB:dbMessage.messageIds];
            }
            
            [RudderLogger logDebug:@"Fetching events to flush to sever"];
            RudderDBMessage *dbMessage = [self->dbpersistenceManager fetchEventsFromDB:(self->config.flushQueueSize)];
            if (dbMessage.messages.count > 0 && (sleepCount >= self->config.sleepTimeout)) {
                NSString* payload = [self __getPayloadFromMessages:dbMessage.messages messageIds:dbMessage.messageIds];
                [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"Payload: %@", payload]];
                if (payload != nil) {
                    NSString* response = [self __flushEventsToServer:payload];
                    [RudderLogger logInfo:[[NSString alloc] initWithFormat:@"Response: %@", response]];
                    [RudderLogger logInfo:[[NSString alloc] initWithFormat:@"EventCount: %lu", (unsigned long)dbMessage.messages.count]];
                    if (response != nil && [response  isEqual: @"OK"]) {
                        [RudderLogger logDebug:@"clearing events from DB"];
                        [self->dbpersistenceManager clearEventsFromDB:dbMessage.messageIds];
                        sleepCount = 0;
                    }
                }
            }
            [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"SleepCount: %d", sleepCount]];
            sleepCount += 1;
            usleep(1000000);
        }
    });
}

- (NSString*) __getPayloadFromMessages: (NSMutableArray<NSString*>*) messages messageIds: (NSMutableArray<NSString*>*) messageIds{
    NSString* sentAt = [Utils getTimestamp];
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"RecordCount: %lu", (unsigned long)messages.count]];
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"sentAtTimeStamp: %@", sentAt]];
    
    NSMutableString* json = [[NSMutableString alloc] init];
    
    [json appendString:@"{"];
    [json appendFormat:@"\"sentAt\":\"%@\",", sentAt];
    [json appendString:@"\"batch\":["];
    unsigned int totalBatchSize = [Utils getUTF8Length:json] + 2;// we add 2 characters at the end
    int index;
    for (index = 0; index < messages.count; index++) {
        NSMutableString* message = [[NSMutableString alloc] initWithString:messages[index]];
        long length = message.length;
        message = [[NSMutableString alloc] initWithString:[message substringWithRange:NSMakeRange(0, (length-1))]];
        [message appendFormat:@",\"sentAt\":\"%@\"},", sentAt];
        // add message size to batch size
        totalBatchSize += [Utils getUTF8Length:message];
        // check totalBatchSize
        if(totalBatchSize > MAX_BATCH_SIZE){
            [RudderLogger logDebug:[NSString stringWithFormat:@"MAX_BATCH_SIZE reached at index: %i | Total: %i",index, totalBatchSize]];
            break;
        }
        [json appendString:message];
    }
    if([json characterAtIndex:[json length]-1] == ',') {
        // remove trailing ','
        [json deleteCharactersInRange:NSMakeRange([json length]-1, 1)];
    }
    [json appendString:@"]}"];
    // remove all events which are not in the current batch
    if(totalBatchSize > MAX_BATCH_SIZE) {
        [messageIds removeObjectsInRange:NSMakeRange(index, messageIds.count-index)];
    }
    
    return [json copy];
}

- (NSString* _Nullable) __flushEventsToServer: (NSString*) payload {
    if (self->authToken == nil || [self->authToken isEqual:@""]) {
        [RudderLogger logError:@"WriteKey was not correct. Aborting flush to server"];
        return nil;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    __block NSString *responseStr = nil;
    NSString *dataPlaneEndPoint = [self->config.dataPlaneUrl stringByAppendingString:@"/v1/batch"];
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"endPointToFlush %@", dataPlaneEndPoint]];
    
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
        
        [RudderLogger logError:[[NSString alloc] initWithFormat:@"statusCode %ld", (long)httpResponse.statusCode]];
        
        if (httpResponse.statusCode == 200) {
            if (data != nil) {
                responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        } else {
            NSString *errorResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [RudderLogger logError:[[NSString alloc] initWithFormat:@"ServerError: %@", errorResponse]];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    [dataTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
#if !__has_feature(objc_arc)
    dispatch_release(semaphore);
#endif
    
    return responseStr;
}

- (void) dump:(RudderMessage *)message {
    if (message == nil) return;
    message.integrations = @{@"All": @YES};
    [self makeFactoryDump: message];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[message dict] options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"dump: %@", jsonString]];
    
    unsigned int messageSize = [Utils getUTF8Length:jsonString];
    if (messageSize > MAX_EVENT_SIZE) {
        [RudderLogger logError:[NSString stringWithFormat:@"dump: Event size exceeds the maximum permitted event size(%iu)", MAX_EVENT_SIZE]];
        return;
    }
    
    [self->dbpersistenceManager saveEvent:jsonString];
}

- (void) makeFactoryDump:(RudderMessage *)message {
    if (self->isFactoryInitialized) {
        [RudderLogger logDebug:@"dumping message to native sdk factories"];
        for (NSString *key in [self->integrationOperationMap allKeys]) {
            [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"dumping for %@", key]];
            id<RudderIntegration> integration = [self->integrationOperationMap objectForKey:key];
            if (integration != nil) {
                [integration dump:message];
            }
        }
    } else {
        [RudderLogger logDebug:@"factories are not initialized. dumping to replay queue"];
        if (self->eventReplayMessage == nil) {
            self->eventReplayMessage = [[NSMutableArray alloc] init];
        }
        [self->eventReplayMessage addObject:message];
    }
}

-(void) reset {
    if (self->isFactoryInitialized) {
        for (NSString *key in [self->integrationOperationMap allKeys]) {
            [RudderLogger logDebug:[[NSString alloc] initWithFormat:@"resetting native SDK for %@", key]];
            id<RudderIntegration> integration = [self->integrationOperationMap objectForKey:key];
            if (integration != nil) {
                [integration reset];
            }
        }
    } else {
        [RudderLogger logDebug:@"factories are not initialized. ignored"];
    }
}

- (void) __prepareIntegrations {
    RudderServerConfigSource *serverConfig = [self->configManager getConfig];
    if (serverConfig != nil) {
        self->integrations = [[NSMutableDictionary alloc] init];
        for (RudderServerDestination *destination in serverConfig.destinations) {
            if ([self->integrations objectForKey:destination.destinationDefinition.definitionName] == nil) {
                [self->integrations setObject:[[NSNumber alloc] initWithBool:destination.isDestinationEnabled] forKey:destination.destinationDefinition.definitionName];
            }
        }
    }
}

- (RudderConfig *)getConfig {
    return self->config;
}

@end
