//
//  RSServerConfigManager.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSServerConfigManager.h"
#import "RSNetworkResponse.h"
#import "RSEnums.h"
#import "RSUtils.h"
#import "RSLogger.h"
#import "RSServerDestination.h"
#import "RSConstants.h"
#import <pthread.h>

static RSServerConfigManager *_instance;
static NSMutableDictionary<NSString*, NSString*>* destinationsWithTransformationsEnabled;
static NSMutableArray<NSString*>* destinationsAcceptingEventsOnTransformationError;
static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
static RSServerConfigSource *serverConfig;

int receivedError = NETWORK_SUCCESS;

@implementation RSServerConfigManager

- (instancetype)init: (NSString*) writeKey rudderConfig:(RSConfig*) rudderConfig andNetworkManager: (RSNetworkManager *) networkManager {
    self = [super init];
    if (self) {
        self->preferenceManager = [RSPreferenceManager getInstance];
        self->networkManager = networkManager;
        if (writeKey == nil || [writeKey isEqualToString:@""]) {
            [RSLogger logError:@"writeKey can not be null or empty"];
            receivedError = WRONG_WRITE_KEY;
        } else {
            self->writeKey = writeKey;
            self->rudderConfig = rudderConfig;
            // fetchConfig and populate serverConfig
            __weak RSServerConfigManager *weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                RSServerConfigManager *strongSelf = weakSelf;
                [strongSelf _fetchConfig];
            });
        }
    }
    return self;
}

- (BOOL) _isServerConfigOutDated {
    long currentTime = [RSUtils getTimeStampLong];
    long lastUpdatedTime = [self->preferenceManager getLastUpdatedTime];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Last updated config time: %ld", lastUpdatedTime]];
    return (currentTime - lastUpdatedTime) > (rudderConfig.configRefreshInterval * 60 * 60 * 1000);
}

- (RSServerConfigSource* _Nullable) _retrieveConfig {
    NSString* configStr = [self->preferenceManager getConfigJson];
    [RSLogger logDebug:[[NSString alloc] initWithFormat:@"configJson: %@", configStr]];
    if (configStr == nil) {
        return nil;
    } else {
        return [self _parseConfig:configStr];
    }
}

- (RSServerConfigSource *_Nullable)_parseConfig:(NSString *)configStr {
    NSDictionary *configDict = [RSUtils deserialize:configStr];
    
    RSServerConfigSource *source;
    if (configDict != nil) {
        source = [[RSServerConfigSource alloc] initWithConfigDict:configDict];
        for (RSServerDestination *destination in source.destinations) {
            if (destination.shouldApplyDeviceModeTransformation) {
                if(destinationsWithTransformationsEnabled == nil) {
                    destinationsWithTransformationsEnabled = [[NSMutableDictionary alloc] init];
                }
                destinationsWithTransformationsEnabled[destination.destinationDefinition.displayName] = destination.destinationId;
                if (destination.propagateEventsUntransformedOnError) {
                    if(destinationsAcceptingEventsOnTransformationError == nil) {
                        destinationsAcceptingEventsOnTransformationError = [[NSMutableArray alloc] init];
                    }
                    [destinationsAcceptingEventsOnTransformationError addObject:destination.destinationDefinition.displayName];
                }
            }
        }
    } else {
        [RSLogger logError:@"config deserializaion error"];
    }
    
    return source;
}

- (void)_fetchConfig {
    // download and store config to storage
    [self _downloadConfig];
    
    // retrieve config from storage
    pthread_mutex_lock(&mutex);
    serverConfig = [self _retrieveConfig];
    if (serverConfig == nil) {
        [RSLogger logDebug:@"Server config retrieval failed.No config found in storage"];
        [RSLogger logError:[[NSString alloc] initWithFormat:@"Failed to fetch server config for writeKey: %@", writeKey]];
    }
    pthread_mutex_unlock(&mutex);
}

- (void)_downloadConfig {
    BOOL isDone = NO;
    int retryCount = 0;
    while (isDone == NO && retryCount <= 3) {
        RSNetworkResponse* response = [self->networkManager sendNetworkRequest:nil toEndpoint:SOURCE_CONFIG_ENDPOINT withRequestMethod:GET];
        NSString* configJson = response.responsePayload;
        if (response.statusCode == 200 && configJson != nil) {
            [preferenceManager saveConfigJson:configJson];
            [preferenceManager updateLastUpdatedTime:[RSUtils getTimeStampLong]];
            
            [RSLogger logDebug:@"server config download successful"];
            isDone = YES;
        } else {
            if (response.statusCode == 400 || receivedError == 2) {
                receivedError = WRONG_WRITE_KEY;
                [RSLogger logInfo:@"Wrong write key"];
                retryCount = 4;
            } else {
                [RSLogger logInfo:[[NSString alloc] initWithFormat:@"Retrying download in %d seconds", retryCount]];
                retryCount += 1;
                usleep(1000000 * retryCount);
            }
        }
    }
    if (!isDone) {
        [RSLogger logError:@"Server config download failed.Using last stored config from storage"];
    }
}

- (RSServerConfigSource *) getConfig {
    pthread_mutex_lock(&mutex);
    RSServerConfigSource *config = serverConfig;
    pthread_mutex_unlock(&mutex);
    return config;
}

- (NSDictionary<NSString*, NSString*>*) getDestinationsWithTransformationsEnabled {
    pthread_mutex_lock(&mutex);
    NSDictionary<NSString*, NSString*>* transformationsEnabledDestinations = [destinationsWithTransformationsEnabled copy];
    pthread_mutex_unlock(&mutex);
    return transformationsEnabledDestinations;
}

- (NSArray<NSString*>*) getDestinationsAcceptingEventsOnTransformationError {
    pthread_mutex_lock(&mutex);
    NSArray<NSString*>* destinationsAcceptingEvents = [destinationsAcceptingEventsOnTransformationError copy];
    pthread_mutex_unlock(&mutex);
    return destinationsAcceptingEvents;
}

- (int) getError {
    return  receivedError;
}

@end
