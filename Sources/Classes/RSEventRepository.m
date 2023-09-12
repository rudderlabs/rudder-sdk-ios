//
//  EventRepository.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSEventRepository.h"
#import "RSMetricsReporter.h"

static RSEventRepository* _instance;
@implementation RSEventRepository

+ (instancetype)initiate:(NSString *)writeKey config:(RSConfig *)config client:(RSClient *)client options:(RSOption * __nullable)options {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init:writeKey config:config client:client options:options];
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
 * 2. Initiate RSElementCache
 * 3. Initiate RSNetworkManager
 * 4. Initiate RSServerConfigManager
 * 5. Initiate RSPreferenceManager
 * 6. Initiate RSDBPersistentManager for SQLite operations
 * 7. Initiate RSCloudModeManager
 * 8. Initiate RSFlushManager
 * 9. Initiate RSDeviceModeManager
 * 10.Initiate SDK
 * 11.Initiate RSBackGroundModeManager
 * 12.Initiate RSApplicationLifeCycleManager
 * */
- (instancetype)init:(NSString*)_writeKey config:(RSConfig*)_config client:(RSClient *)_client options:(RSOption * __nullable)_options {
    self = [super init];
    if (self) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: writeKey: %@", _writeKey]];
        
        self->isSDKEnabled = YES;
        self->isSDKInitialized = NO;
        self->client = _client;
        
        self->writeKey = _writeKey;
        self->config = _config;
        self->defaultOptions = _options;
        
        self->authToken = [RSUtils getBase64EncodedString: [[NSString alloc] initWithFormat:@"%@:", self->writeKey]];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSPreferenceManager"];
        self->preferenceManager = [RSPreferenceManager getInstance];
        [self->preferenceManager performMigration];
        
        [self clearAnonymousIdIfRequired];
        
        [RSLogger logVerbose:@"EventRepository: Creating EventRepository Internal Queue"];
        repositoryQueue = dispatch_queue_create("com.rudder.EventRepository", NULL);
        
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: authToken: %@", authToken]];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSElementCache"];
        [RSElementCache initiateWithConfig:self->config];
        
        [RSLogger logDebug:@"EventRepository: Setting AnonymousId Token"];
        [self setAnonymousIdToken];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSDataResidencyManager"];
        self->dataResidencyManager = [[RSDataResidencyManager alloc] initWithRSConfig:_config];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSNetworkManager"];
        self->networkManager = [[RSNetworkManager alloc] initWithConfig:config andAuthToken:authToken andAnonymousIdToken:anonymousIdToken andDataResidencyManager:self->dataResidencyManager];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSServerConfigManager"];
        self->configManager = [[RSServerConfigManager alloc] init:writeKey rudderConfig:config andNetworkManager:self->networkManager];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSMetricsReporter"];
        [RSMetricsReporter initiateWithWriteKey:_writeKey preferenceManager:self->preferenceManager andConfig:_config];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSDBPersistentManager"];
        self->dbpersistenceManager = [[RSDBPersistentManager alloc] initWithDBEncryption:_config.dbEncryption];
        [self->dbpersistenceManager createTables];
        [self->dbpersistenceManager checkForMigrations];
        
        self->lock = [[NSLock alloc] init];
        [RSLogger logDebug:@"EventRepository: Initiating RSCloudModeManager"];
        self->cloudModeManager = [[RSCloudModeManager alloc] initWithConfig:config andDBPersistentManager: self->dbpersistenceManager andNetworkManager:self->networkManager andLock:lock];
        
        [RSLogger logDebug:@"EventRepository: Initiating and Setting up RSFlushManager"];
        self->flushManager = [[RSFlushManager alloc] initWithConfig:config andPersistentManager:self->dbpersistenceManager andNetworkManager:self->networkManager andLock:self->lock];
        [self->flushManager setUpFlush];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSDeviceModeManager"];
        self->deviceModeManager = [[RSDeviceModeManager alloc] initWithConfig:config andDBPersistentManager:self->dbpersistenceManager andNetworkManager:self->networkManager];
        
        [RSLogger logDebug:@"EventRepository: Initiating the SDK"];
        [self __initiateSDK];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSBackGroundModeManager"];
        self->backGroundModeManager = [[RSBackGroundModeManager alloc] initWithConfig:_config];
        
        [RSLogger logDebug:@"EventRepository: Initiating User Session Manager"];
        self->userSession = [RSUserSession initiate:self->config.sessionInActivityTimeOut with: self->preferenceManager];
        
        // clear session if automatic session tracking was enabled previously but disabled presently or vice versa.
        BOOL currentAutoTrackingStatus = self->config.automaticSessionTracking && self->config.trackLifecycleEvents;
        BOOL previousAutoTrackingStatus = [self->preferenceManager getAutoTrackingStatus];
        if(previousAutoTrackingStatus && previousAutoTrackingStatus != currentAutoTrackingStatus) {
            [RSLogger logDebug:@"EventRepository: Automatic Session Tracking status has been updated since last launch, hence clearing the session"];
            [self->userSession clearSession];
        }
        if(currentAutoTrackingStatus) {
            [self->preferenceManager saveAutoTrackingStatus:YES];
            [RSLogger logDebug:@"EventRepository: Starting Automatic Sessions"];
            [self->userSession startSessionIfExpired];
        } else {
            [self->preferenceManager saveAutoTrackingStatus:NO];
        }
        
        [RSLogger logDebug:@"EventRepository: Initiating RSApplicationLifeCycleManager"];
        self->applicationLifeCycleManager = [[RSApplicationLifeCycleManager alloc] initWithConfig:config andPreferenceManager:self->preferenceManager andBackGroundModeManager:self->backGroundModeManager andUserSession:self->userSession];
        
        [RSLogger logDebug:@"EventRepository: Enabling tracking of application lifecycle events"];
        [self->applicationLifeCycleManager trackApplicationLifeCycle];
        
        if (config.recordScreenViews) {
            [RSLogger logDebug:@"EventRepository: Enabling automatic recording of screen views"];
            [self->applicationLifeCycleManager prepareScreenRecorder];
        }
    }
    return self;
}

// If the collectDeviceId flag is set to false, then check if deviceId is being used as anonymousId, if yes then clear it
-(void) clearAnonymousIdIfRequired {
    if(config.collectDeviceId) return;
    NSString* currentAnonymousId = [self->preferenceManager getAnonymousId];
    NSString* deviceId = [RSUtils getDeviceId];
    if(currentAnonymousId == nil || deviceId == nil) return;
    if([currentAnonymousId isEqualToString:deviceId]) {
        [self->preferenceManager clearCurrentAnonymousIdValue];
    }
}

- (void) setAnonymousIdToken {
    NSData *anonymousIdData = [[[NSString alloc] initWithFormat:@"%@:", [RSElementCache getAnonymousId]] dataUsingEncoding:NSUTF8StringEncoding];
    dispatch_sync(repositoryQueue, ^{
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
            int receivedError = [strongSelf->configManager getError];
            if (serverConfig != nil) {
                [RSMetricsReporter setMetricsCollectionEnabled:serverConfig.isMetricsCollectionEnabled];
                [RSMetricsReporter setErrorsCollectionEnabled:serverConfig.isErrorsCollectionEnabled];
                // initiate the processor if the source is enabled
                dispatch_sync(strongSelf->repositoryQueue, ^{
                    strongSelf->isSDKEnabled = serverConfig.isSourceEnabled;
                });
                if (strongSelf->isSDKEnabled) {
                    [self->dataResidencyManager setDataResidencyUrlFromSourceConfig: serverConfig];
                    NSString* dataPlaneUrl = [self->dataResidencyManager getDataPlaneUrl];
                    if (dataPlaneUrl == nil) {
                        [RSLogger logError:DATA_PLANE_URL_ERROR];
                        return;
                    }
                    [RSLogger logDebug:@"EventRepository: Starting Cloud Mode Processor"];
                    [self-> cloudModeManager startCloudModeProcessor];
                    if (strongSelf->config.consentFilter != nil) {
                        [RSLogger logDebug:@"EventRepository: Initiating ConsentFilterHandler"];
                        strongSelf->consentFilterHandler = [RSConsentFilterHandler initiate:strongSelf->config.consentFilter withServerConfig:serverConfig];
                    }
                    
                    // initiate the native SDK factories if destinations are present
                    if (serverConfig.destinations != nil && serverConfig.destinations.count > 0) {
                        NSArray <RSServerDestination *> *consentedDestinations = self->consentFilterHandler != nil ? [self->consentFilterHandler filterDestinationList:serverConfig.destinations] : serverConfig.destinations;
                        if(consentedDestinations != nil && consentedDestinations.count > 0 ) {
                            [self->deviceModeManager startDeviceModeProcessor:consentedDestinations withConfigManager:strongSelf->configManager];
                        }
                    } else {
                        [self->deviceModeManager handleCaseWhenNoDeviceModeFactoryIsPresent];
                        [RSLogger logDebug:@"EventRepository: no device mode present"];
                    }
                    [RSMetricsReporter report:SDKMETRICS_SC_ATTEMPT_SUCCESS forMetricType:COUNT withProperties:nil andValue:1];
                } else {
                    [RSLogger logDebug:@"EventRepository: source is disabled in your Dashboard"];
                    [RSMetricsReporter report:SDKMETRICS_SC_ATTEMPT_ABORT forMetricType:COUNT withProperties:@{SDKMETRICS_TYPE: SDKMETRICS_SOURCE_DISABLED} andValue:1];
                    [strongSelf->dbpersistenceManager flushEventsFromDB];
                }
                strongSelf->isSDKInitialized = YES;
            } else if (receivedError == 2) {
                retryCount = 6;
                [RSLogger logError:@"WRONG WRITE KEY"];
            } else {
                retryCount += 1;
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"server config is null. retrying in %ds.", 2 * retryCount]];
                usleep(1000000 * 2 * retryCount);
            }
        }
    });
}

- (void) dump:(RSMessage *)message {
    [RSMetricsReporter report:SDKMETRICS_SUBMITTED_EVENTS forMetricType:COUNT withProperties:@{SDKMETRICS_TYPE: message.type} andValue:1];
    dispatch_sync(repositoryQueue, ^{
        if (message == nil || !self->isSDKEnabled) {
            if (!self->isSDKEnabled)
                [RSMetricsReporter report:SDKMETRICS_EVENTS_DISCARDED forMetricType:COUNT withProperties:@{SDKMETRICS_TYPE: SDKMETRICS_SDK_DISABLED} andValue:1];
            return;
        }
    });
    [self applyIntegrations:message withDefaultOption:self->defaultOptions];
    message = [self applyConsents:message];
    [self applySession:message withUserSession:userSession andRudderConfig:config];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[message dict] options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"dump: %@", jsonString]];
    unsigned int messageSize = [RSUtils getUTF8Length:jsonString];
    if (messageSize > MAX_EVENT_SIZE) {
        [RSLogger logError:[NSString stringWithFormat:@"dump: Event size exceeds the maximum permitted event size(%iu)", MAX_EVENT_SIZE]];
        [RSMetricsReporter report:SDKMETRICS_EVENTS_DISCARDED forMetricType:COUNT withProperties:@{SDKMETRICS_TYPE: SDKMETRICS_MSG_SIZE_INVALID} andValue:1];
        return;
    }
    NSNumber* rowId = [self->dbpersistenceManager saveEvent:jsonString];
    [self->deviceModeManager makeFactoryDump: message FromHistory:NO withRowId:rowId];
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

-(void) reset {
    if([self->userSession getSessionId] != nil) {
        [RSLogger logDebug: @"EventRepository: reset: Refreshing the session as the reset is triggered"];
        [self->userSession refreshSession];
    }
    
    [RSLogger logDebug: @"EventRepository: reset: clearing the CTS Auth token as the reset is triggered"];
    [self->preferenceManager clearAuthToken];
    
    [self->deviceModeManager reset];
}

-(void) flush {
    if ([self->dataResidencyManager getDataPlaneUrl] == nil) {
        [RSLogger logError:DATA_PLANE_URL_FLUSH_ERROR];
        return;
    }
    [self->deviceModeManager flush];
    [self->flushManager flush];
}

-(void) applicationDidFinishLaunchingWithOptions:(NSDictionary *) launchOptions {
    [self->applicationLifeCycleManager applicationDidFinishLaunchingWithOptions:launchOptions];
}

- (void) prepareIntegrations {
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

- (NSNumber * _Nullable)getSessionId {
    return [self->userSession getSessionId];
}

@end
