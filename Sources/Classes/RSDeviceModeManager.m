//
//  RSDeviceModeManager.m
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSConfig.h"
#import "RSLogger.h"
#import "RSServerDestination.h"
#import "RSDeviceModeManager.h"
#import "RSDeviceModeTransformationManager.h"

@implementation RSDeviceModeManager

- (instancetype)initWithConfig:(RSConfig *) config andDBPersistentManager:(RSDBPersistentManager *)dbPersistentManager andNetworkManager:(RSNetworkManager *)networkManager {
    self = [super init];
    if(self) {
        self->config = config;
        self->dbPersistentManager = dbPersistentManager;
        self->networkManager = networkManager;
        self->integrationOperationMap = [[NSMutableDictionary alloc] init];
        self->eventReplayMessage = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) startDeviceModeProcessor:(RSServerConfigSource *) serverConfig andDestinationsWithTransformationsEnabled: (NSDictionary<NSString*, NSString*>*) destinationsWithTransformationsEnabled {
    self->serverConfig = serverConfig;
    self->destinationsWithTransformationsEnabled = destinationsWithTransformationsEnabled;
    self->eventFilteringPlugin = [[RSEventFilteringPlugin alloc] init:serverConfig.destinations];
    [self initiateFactories:self->serverConfig.destinations];
    // this might fail if serverConfig is nil, need to handle
    [self initiateCustomFactories];
    [self replayMessageQueue];
    self->areFactoriesInitialized = YES;
    // initaiting the transformation processor only if there are any device mode destinations with transformations enabled
    if([self-> destinationsWithTransformationsEnabled count] > 0){
        RSDeviceModeTransformationManager* deviceModeTransformationManager = [[RSDeviceModeTransformationManager alloc] initWithConfig:self->config andDBPersistentManager:self->dbPersistentManager andDeviceModeManager:self andNetworkManager:self->networkManager];
        [deviceModeTransformationManager startTransformationProcessor];
    }
}

- (void) initiateFactories : (NSArray*) destinations {
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
                        @try {
                            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Initiating native SDK factory %@", factory.key]];
                            id<RSIntegration> nativeOp = [factory initiate:destinationConfig client:[RSClient sharedInstance] rudderConfig:self->config];
                            [integrationOperationMap setValue:nativeOp forKey:factory.key];
                            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Initiated native SDK factory %@", factory.key]];
                        }
                        @catch(NSException* e){
                            [RSLogger logError:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: initiateFactories: Exception while initiating native SDK Factory %@ due to %@", factory.key,e.reason]];
                        }
                    }
                }
            }
        }
    }
}

- (void) initiateCustomFactories {
    if (self->config == nil || config.customFactories == nil || config.customFactories.count == 0) {
        [RSLogger logInfo:@"EventRepository: initiateCustomFactories: No custom factory found"];
        return;
    }
    for (id<RSIntegrationFactory> factory in self->config.customFactories) {
        @try {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Initiating custom factory %@", factory.key]];
            id<RSIntegration> nativeOp = [factory initiate:@{} client:[RSClient sharedInstance] rudderConfig:self->config];
            [self->integrationOperationMap setValue:nativeOp forKey:factory.key];
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"Initiated custom SDK factory %@", factory.key]];
        }
        @catch(NSException* e){
            [RSLogger logError:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: initiateFactories: Exception while initiating custom Factory %@ due to %@", factory.key,e.reason]];
        }
    }
}

- (void) replayMessageQueue {
    @synchronized (self->eventReplayMessage) {
        [RSLogger logDebug:@"replaying old messages with factory"];
        if (self->eventReplayMessage.count > 0) {
            for (RSMessage *message in eventReplayMessage) {
                [self makeFactoryDump:message FromHistory:YES];
            }
        }
        [self->eventReplayMessage removeAllObjects];
    }
}

- (void) makeFactoryDump:(RSMessage *)message FromHistory:(BOOL) fromHistory {
    if (self->areFactoriesInitialized || fromHistory) {
        [RSLogger logDebug:@"dumping message to native sdk factories"];
        NSDictionary<NSString*, NSObject*>*  integrationOptions = message.integrations;
        // If All is set to true we will dump to all the integrations which are not set to false
        for (NSString *key in [self->integrationOperationMap allKeys]) {
            
            if(([(NSNumber*)integrationOptions[@"All"] boolValue] && (integrationOptions[key]==nil)) || ([(NSNumber*)integrationOptions[key] boolValue]))
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
                            [RSLogger logVerbose:[[NSString alloc] initWithFormat:@"Destination %@ needs transformation, hence batching it to send to transformation service", key]];
                        }
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

-(void) dumpTransformedEvents:(NSArray*) transformedPayloads ToDestination:(NSString*) destinationId {
    for (NSDictionary* transformedPayload in transformedPayloads) {
        NSString* status = transformedPayload[@"status"];
        if([status isEqualToString:@"200"]) {
            RSMessage* transformedMessage = [[RSMessage alloc] initWithDict:transformedPayload[@"event"]];
            NSArray<NSString*>* destinationNames = [self->destinationsWithTransformationsEnabled allKeysForObject:destinationId];
            if(destinationNames.count >0) {
                NSString* destinationName = destinationNames[0];
                id<RSIntegration> integration = [self->integrationOperationMap objectForKey:destinationName];
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"dumping the transformed event %@ for %@", transformedMessage.event, destinationName]];
                [integration dump:transformedMessage];
            }
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
@end
