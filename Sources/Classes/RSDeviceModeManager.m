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
        self->eventReplayMessage = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void) startDeviceModeProcessor:(RSServerConfigSource *) serverConfig andDestinationsWithTransformationsEnabled: (NSDictionary<NSString*, NSString*>*) destinationsWithTransformationsEnabled {
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Starting the Device Mode Processor"];
    self->serverConfig = serverConfig;
    self->destinationsWithTransformationsEnabled = destinationsWithTransformationsEnabled;
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Initializing the Event Filtering Plugin"];
    self->eventFilteringPlugin = [[RSEventFilteringPlugin alloc] init:serverConfig.destinations];
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Initializing the Device Mode Factories"];
    [self initiateFactories:self->serverConfig.destinations];
    // this might fail if serverConfig is nil, need to handle
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Initializing the Custom Factories"];
    [self initiateCustomFactories];
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Replaying the message queue to the Factories"];
    [self replayMessageQueue];
    self->areFactoriesInitialized = YES;
    // initaiting the transformation processor only if there are any device mode destinations with transformations enabled
    if([self-> destinationsWithTransformationsEnabled count] > 0){
        RSDeviceModeTransformationManager* deviceModeTransformationManager = [[RSDeviceModeTransformationManager alloc] initWithConfig:self->config andDBPersistentManager:self->dbPersistentManager andDeviceModeManager:self andNetworkManager:self->networkManager];
        [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Starting the Device Mode Transformation Processor"];
        [deviceModeTransformationManager startTransformationProcessor];
    }
}

- (void) initiateFactories : (NSArray*) destinations {
    if (self->config == nil || config.factories == nil || config.factories.count == 0) {
        [RSLogger logInfo:@"RSDeviceModeManager: initiateFactories: No native SDK is found in the config"];
        return;
    } else {
        if (destinations.count == 0) {
            [RSLogger logInfo:@"RSDeviceModeManager: initiateFactories: No native SDK factory is found in the server config"];
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
                            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: initiateFactories: Initiating native SDK factory %@", factory.key]];
                            id<RSIntegration> nativeOp = [factory initiate:destinationConfig client:[RSClient sharedInstance] rudderConfig:self->config];
                            [integrationOperationMap setValue:nativeOp forKey:factory.key];
                            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: initiateFactories: Initiated native SDK factory %@", factory.key]];
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
        [RSLogger logInfo:@"RSDeviceModeManager: initiateCustomFactories: No custom factory found"];
        return;
    }
    for (id<RSIntegrationFactory> factory in self->config.customFactories) {
        @try {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: initiateCustomFactories: Initiating custom factory %@", factory.key]];
            id<RSIntegration> nativeOp = [factory initiate:@{} client:[RSClient sharedInstance] rudderConfig:self->config];
            [self->integrationOperationMap setValue:nativeOp forKey:factory.key];
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: initiateCustomFactories: Initiated custom SDK factory %@", factory.key]];
        }
        @catch(NSException* e){
            [RSLogger logError:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: initiateCustomFactories: Exception while initiating custom Factory %@ due to %@", factory.key,e.reason]];
        }
    }
}

- (void) replayMessageQueue {
    @synchronized (self->eventReplayMessage) {
        [RSLogger logDebug:@"RSDeviceModeManager: replayMessageQueue: replaying old messages with factory"];
        if (self->eventReplayMessage.count > 0) {
            NSMutableArray<NSNumber*>* rowIds = [self->eventReplayMessage.allKeys mutableCopy];
            [RSUtils sortArray:rowIds inOrder:ASCENDING];
            for(NSNumber* rowId in rowIds) {
                [self makeFactoryDump:eventReplayMessage[rowId] FromHistory:YES withRowId:rowId];
            }
        }
        [self->eventReplayMessage removeAllObjects];
    }
}

- (void) makeFactoryDump:(RSMessage *)message FromHistory:(BOOL) fromHistory withRowId:(NSNumber *) rowId {
    if (self->areFactoriesInitialized || fromHistory) {
        BOOL isTransformationNeeded = NO;
        [RSLogger logVerbose:@"RSDeviceModeManager: makeFactoryDump: dumping message to native sdk factories"];
        for (NSString *destinationName in [self->integrationOperationMap allKeys]) {
            if([self isEvent:message allowedForDestination:destinationName]) {
                id<RSIntegration> integration = [self->integrationOperationMap objectForKey:destinationName];
                if (integration != nil) {
                    if(destinationsWithTransformationsEnabled[destinationName] == nil) {
                        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: makeFactoryDump: dumping for %@", destinationName]];
                        [integration dump:message];
                    } else {
                        isTransformationNeeded = YES;
                        [RSLogger logVerbose:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: makeFactoryDump: Destination %@ needs transformation, hence batching it to send to transformation service", destinationName]];
                    }
                }
            }
        }
        // If an event doesn't needs transformation immediately mark its status as device mode processing done in the events table
        if(!isTransformationNeeded) {
            [self->dbPersistentManager updateEventWithId:rowId withStatus:DEVICE_MODE_PROCESSING_DONE];
        }
    }  else {
        @synchronized (self->eventReplayMessage) {
            [RSLogger logDebug:@"RSDeviceModeManager: makeFactoryDump: factories are not initialized. dumping to replay queue"];
            self->eventReplayMessage[rowId] = message;
        }
    }
}


- (void) dumpOriginalEvents:(NSArray *) originalPayloads {
    for(NSDictionary* originalPayload in originalPayloads) {
        RSMessage* originalMessage = [[RSMessage alloc] initWithDict:originalPayload[@"event"]];
        NSArray<NSString *> * transformationEnabledDestinations = [self getTransformationEnabledDestinationsForMessage:originalMessage];
        for(NSString *transformationEnabledDestination in transformationEnabledDestinations) {
            id<RSIntegration> integration = [self->integrationOperationMap objectForKey:transformationEnabledDestination];
            if(integration != nil) {
                [RSLogger logWarn:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: dumpOriginalEvents: dumping the original event %@ for %@ as device mode transformations are not enabled", originalMessage.event, transformationEnabledDestination]];
                [integration dump:originalMessage];
            }
        }
    }
}

-(void) dumpTransformedEvents:(NSArray*) transformedPayloads ToDestination:(NSString*) destinationId {
    for (NSDictionary* transformedPayload in transformedPayloads) {
        NSString* status = transformedPayload[@"status"];
        if(status !=nil && [status isEqualToString:@"200"]) {
            NSDictionary* event = transformedPayload[@"event"];
            if(event != nil) {
                RSMessage* transformedMessage = [[RSMessage alloc] initWithDict:transformedPayload[@"event"]];
                NSArray<NSString*>* destinationNames = [self->destinationsWithTransformationsEnabled allKeysForObject:destinationId];
                if(destinationNames.count >0) {
                    NSString* destinationName = destinationNames[0];
                    id<RSIntegration> integration = [self->integrationOperationMap objectForKey:destinationName];
                    if(integration != nil) {
                        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: dumpTransformedEvents: dumping the transformed event %@ for %@", transformedMessage.event, destinationName]];
                        [integration dump:transformedMessage];
                    }
                }
            }
        }
    }
}

-(void) reset {
    if (self->areFactoriesInitialized) {
        for (NSString *key in [self->integrationOperationMap allKeys]) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: reset: resetting native SDK for %@", key]];
            id<RSIntegration> integration = [self->integrationOperationMap objectForKey:key];
            if (integration != nil) {
                [integration reset];
            }
        }
    } else {
        [RSLogger logDebug:@"RSDeviceModeManager: reset: factories are not initialized. ignoring reset call"];
    }
}

-(void) flush {
    if (self->areFactoriesInitialized) {
        for (NSString *key in [self->integrationOperationMap allKeys]) {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: flush: flushing native SDK for %@", key]];
            id<RSIntegration> integration = [self->integrationOperationMap objectForKey:key];
            if (integration != nil) {
                [integration flush];
            }
        }
    } else {
        [RSLogger logDebug:@"RSDeviceModeManager: flush: factories are not initialized. ignoring flush call"];
    }
}

- (BOOL) isEvent:(RSMessage *) message allowedForDestination: (NSString *) destinationName {
    BOOL isDestinationEnabledForMessage = [self isDestination:destinationName enabledForMessage:message];
    BOOL isEventAllowedForDestination = [self->eventFilteringPlugin isEventAllowed:message ForDestination:destinationName];
    return isDestinationEnabledForMessage && isEventAllowedForDestination;
}

- (BOOL) isDestination:(NSString *) destinationName enabledForMessage:(RSMessage *) message {
    NSDictionary<NSString*, NSObject*>*  integrationOptions = message.integrations;
    // If All is set to true and the destination is absent in the integrations object
    BOOL isAllTrueAndDestinationAbsent = [(NSNumber*)integrationOptions[@"All"] boolValue] && (integrationOptions[destinationName]==nil);
    // If the destination is present and true in the integrations object
    BOOL isDestinationEnabled = [(NSNumber*)integrationOptions[destinationName] boolValue];
    return isAllTrueAndDestinationAbsent || isDestinationEnabled;
}

- (NSArray<NSString *> *) getTransformationEnabledDestinationsForMessage:(RSMessage *) message {
    NSMutableArray<NSString *>* transformationEnabledDestinations = [[NSMutableArray alloc] init];
    for(NSString* destinationName in [self->destinationsWithTransformationsEnabled allKeys]) {
        if([self isDestination:destinationName enabledForMessage:message]) {
            [transformationEnabledDestinations addObject:destinationName];
        }
    }
    return transformationEnabledDestinations;
}

@end
