//
//  EventRepository.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSEventRepository.h"

static RSEventRepository* _instance;
@implementation RSEventRepository

+ (instancetype)initiate:(NSString *)writeKey config:(RSConfig *) config {
    if (_instance == nil) {
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

- (instancetype)init : (NSString*) _writeKey config:(RSConfig*) _config {
    self = [super init];
    if (self) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: writeKey: %@", _writeKey]];
        
        self->isSDKEnabled = YES;
        self->isSDKInitialized = NO;
        
        writeKey = _writeKey;
        config = _config;
        
        NSData *authData = [[[NSString alloc] initWithFormat:@"%@:", _writeKey] dataUsingEncoding:NSUTF8StringEncoding];
        authToken = [authData base64EncodedStringWithOptions:0];
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"EventRepository: authToken: %@", authToken]];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSElementCache"];
        [RSElementCache initiate];
        
        [RSLogger logDebug:@"EventRepository: Setting AnonymousId Token"];
        [self setAnonymousIdToken];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSNetworkManager"];
        self->networkManager = [[RSNetworkManager alloc] initWithConfig:config andAuthToken:authToken andAnonymousIdToken:anonymousIdToken];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSServerConfigManager"];
        self->configManager = [[RSServerConfigManager alloc] init:writeKey rudderConfig:config andNetworkManager:self->networkManager];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSPreferenceManager"];
        self->preferenceManager = [RSPreferenceManager getInstance];
        
        [RSLogger logDebug:@"EventRepository: Initiating RSDBPersistentManager"];
        self->dbpersistenceManager = [[RSDBPersistentManager alloc] init];
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
        
        [RSLogger logDebug:@"EventRepository: Initiating RSApplicationLifeCycleManager"];
        self->applicationLifeCycleManager = [[RSApplicationLifeCycleManager alloc] initWithConfig:config andPreferenceManager:self->preferenceManager andBackGroundModeManager:self->backGroundModeManager];
        
        if (config.trackLifecycleEvents) {
            [RSLogger logDebug:@"EventRepository: Enabling tracking of application lifecycle events"];
            [self->applicationLifeCycleManager trackApplicationLifeCycle];
        }
        
        if (config.recordScreenViews) {
            [RSLogger logDebug:@"EventRepository: Enabling automatic recording of screen views"];
            [self->applicationLifeCycleManager prepareScreenRecorder];
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
                    [RSLogger logDebug:@"EventRepository: Starting Cloud Mode Processor"];
                    [self-> cloudModeManager startCloudModeProcessor];
                    
                    // initiate the native SDK factories if destinations are present
                    if (serverConfig.destinations != nil && serverConfig.destinations.count > 0) {
                        [RSLogger logDebug:@"EventRepository: Starting Device Mode Processor"];
                        [self->deviceModeManager startDeviceModeProcessor:serverConfig andDestinationsWithTransformationsEnabled:[strongSelf->configManager getDestinationsWithTransformationsEnabled]];
                    } else {
                        [RSLogger logDebug:@"EventRepository: no device mode present"];
                    }
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
    if(message.integrations[@"All"]==nil) {
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
    [self->deviceModeManager makeFactoryDump: message FromHistory:NO withRowId:rowId];
}

- (void) reset {
    [self->deviceModeManager reset];
}

-(void) flush {
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

@end
