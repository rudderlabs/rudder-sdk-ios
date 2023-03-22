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

- (void) startDeviceModeProcessor:(NSArray<RSServerDestination*>*) destinations andDestinationsWithTransformationsEnabled: (NSDictionary<NSString*, NSString*>*) destinationsWithTransformationsEnabled {
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Starting the Device Mode Processor"];
    self->destinationsWithTransformationsEnabled = destinationsWithTransformationsEnabled;
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Initializing the Event Filtering Plugin"];
    self->eventFilteringPlugin = [[RSEventFilteringPlugin alloc] init:destinations];
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Initializing the Device Mode Factories"];
    [self initiateFactories:destinations];
    // this might fail if serverConfig is nil, need to handle
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Initializing the Custom Factories"];
    [self initiateCustomFactories];
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Replaying the message queue to the Factories"];
    [self replayMessageQueue];
    self->areFactoriesInitialized = YES;
    // initaiting the transformation processor only if there are any factories passed have a device mode transformation connected to them on control plane
    if([self doFactoriesPassedHaveTransformationsEnabled]){
        RSDeviceModeTransformationManager* deviceModeTransformationManager = [[RSDeviceModeTransformationManager alloc] initWithConfig:self->config andDBPersistentManager:self->dbPersistentManager andDeviceModeManager:self andNetworkManager:self->networkManager];
        [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Starting the Device Mode Transformation Processor"];
        [deviceModeTransformationManager startTransformationProcessor];
    } else {
        [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: No Device Mode Destinations with transformations attached hence device mode transformation processor need not to be started"];
    }
}

- (void) initiateFactories : (NSArray*) destinations {
    if (![self areFactoriesPassedInConfig]) {
        [RSLogger logInfo:@"RSDeviceModeManager: initiateFactories: No native SDK is found in the config"];
        return;
    }
    if (destinations.count == 0) {
        [RSLogger logInfo:@"RSDeviceModeManager: initiateFactories: No native SDK factory is found in the server config"];
        return;
    }
    RSClient* client = [RSClient sharedInstance];
    if(client == nil) {
        [RSLogger logInfo:@"RSDeviceModeManager: initiateFactories: RudderClient instance is found to be nil, aborting the initialization of device modes"];
        return;
    }
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
                    id<RSIntegration> nativeOp = [factory initiate:destinationConfig client:client rudderConfig:self->config];
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

- (void) initiateCustomFactories {
    if (![self areCustomFactoriesPassedInConfig]) {
        [RSLogger logInfo:@"RSDeviceModeManager: initiateCustomFactories: No custom factory found"];
        return;
    }
    RSClient* client = [RSClient sharedInstance];
    if(client == nil) {
        [RSLogger logInfo:@"RSDeviceModeManager: initiateCustomFactories: RudderClient instance is found to be nil, aborting the initialization of custom factories"];
        return;
    }
    for (id<RSIntegrationFactory> factory in self->config.customFactories) {
        @try {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: initiateCustomFactories: Initiating custom factory %@", factory.key]];
            id<RSIntegration> nativeOp = [factory initiate:@{} client:client rudderConfig:self->config];
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
        [RSLogger logVerbose:@"RSDeviceModeManager: makeFactoryDump: dumping message to native sdk factories"];
        NSArray<NSString *>* eligibleDestinations = [self getEligibleDestinations:message];
        
        NSArray<NSString *>* destinationsWithTransformations = [self getDestinationsWithTransformationStatus:ENABLED fromDestinations:eligibleDestinations];
        if(destinationsWithTransformations.count == 0){
            [RSLogger logDebug: [[NSString alloc] initWithFormat:@"RSDeviceModeManager: makeFactoryDump: No device mode destinations with transformations for message %@, hence updating it's status to DEVICE_MODE_PROCESSING DONE", message.event]];
            [self->dbPersistentManager updateEventWithId:rowId withStatus:DEVICE_MODE_PROCESSING_DONE];
        } else {
            for (NSString * destination in destinationsWithTransformations) {
                [RSLogger logDebug: [[NSString alloc] initWithFormat:@"RSDeviceModeManager: makeFactoryDump: Device Mode Destination %@ needs transformation hence it will be batched and sent to the transformation service", destination]];
            }
        }
        
        NSArray<NSString *>* destinationsWithoutTransformations = [self getDestinationsWithTransformationStatus:DISABLED fromDestinations:eligibleDestinations];
        [self dumpEvent:message toDestinations:destinationsWithoutTransformations withLogTag:@"makeFactoryDump"];
        
    }  else {
        @synchronized (self->eventReplayMessage) {
            [RSLogger logDebug:@"RSDeviceModeManager: makeFactoryDump: factories are not initialized. dumping to replay queue"];
            self->eventReplayMessage[rowId] = message;
        }
    }
}

- (void) dumpOriginalEvents:(NSArray *) originalPayloads {
    [RSLogger logWarn:@"RSDeviceModeManager: dumpOriginalEvents: Dumping the original events back to the transformation enabled destinations as the transformations feature is not enabled"];
    for(NSDictionary* originalPayload in originalPayloads) {
        RSMessage* originalMessage = [[RSMessage alloc] initWithDict:originalPayload[@"event"]];
        NSArray<NSString *> * transformationEnabledDestinations = [self getDestinationsWithTransformationStatus:ENABLED fromMessage:originalMessage];
        [self dumpEvent:originalMessage toDestinations:transformationEnabledDestinations withLogTag:@"dumpOriginalEvents"];
    }
}

-(void) dumpTransformedEvents:(NSArray*) transformedPayloads ToDestinationId:(NSString*) destinationId {
    NSArray<NSString*>* destinationNames = [self->destinationsWithTransformationsEnabled allKeysForObject:destinationId];
    if(destinationNames.count > 0) {
        NSString* destinationName = destinationNames[0];
        [RSLogger logDebug: [[NSString alloc] initWithFormat:@"RSDeviceModeManager: dumpTransformedEvents: Dumping back the transformed events to the destination %@", destinationName]];
        for (NSDictionary* transformedPayload in transformedPayloads) {
            NSString* status = transformedPayload[@"status"];
            if(status !=nil && [status isEqualToString:@"200"]) {
                NSDictionary* event = transformedPayload[@"event"];
                if(event != nil) {
                    RSMessage* transformedMessage = [[RSMessage alloc] initWithDict:transformedPayload[@"event"]];
                    [self dumpEvent:transformedMessage toDestinations:@[destinationName] withLogTag:@"dumpTransformedEvents"];
                }
            }
        }
    }
}

-(void) dumpEvent:(RSMessage *) message toDestinations:(NSArray<NSString *> *) destinations withLogTag:(NSString *) logTag {
    for(NSString* destination in destinations) {
        id<RSIntegration> integration = [self->integrationOperationMap objectForKey:destination];
        if(integration != nil) {
            @try {
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: %@: dumping event %@ to factory %@", logTag, message.event, destination]];
                [integration dump:message];
            } @catch(NSException *e) {
                [RSLogger logError:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: %@: Exception while dumping %@ to factory %@ due to %@", logTag, message.event, destination, e.reason]];
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

- (NSArray<NSString *> *) getEligibleDestinations:(RSMessage *) message {
    NSMutableArray<NSString *>* eligibleDestinations = [[NSMutableArray alloc] init];
    for(NSString * destinationName in [self->integrationOperationMap allKeys]) {
        if([self isEvent:message allowedForDestination:destinationName]) {
            [eligibleDestinations addObject:destinationName];
        }
    }
    return eligibleDestinations;
}

- (NSArray<NSString *> *) getDestinationsWithTransformationStatus:(TRANSFORMATION_STATUS) status fromDestinations:(NSArray<NSString *> *) inputDestinations {
    NSMutableArray<NSString *>* outputDestinations = [[NSMutableArray alloc] init];
    for(NSString* inputDestination in inputDestinations) {
        BOOL isTransformationEnabledDestination = [[self->destinationsWithTransformationsEnabled allKeys] containsObject:inputDestination];
        if(status == isTransformationEnabledDestination){
            [outputDestinations addObject:inputDestination];
        }
    }
    return outputDestinations;
}

- (NSArray<NSString *> *) getDestinationsWithTransformationStatus:(TRANSFORMATION_STATUS) status fromMessage:(RSMessage *) message {
    NSArray<NSString *>* inputDestinations = [self getEligibleDestinations:message];
    return [self getDestinationsWithTransformationStatus:status fromDestinations:inputDestinations];
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


- (BOOL) doFactoriesPassedHaveTransformationsEnabled {
    if(![self areFactoriesPassedInConfig])
        return NO;
    for(id<RSIntegrationFactory> factory in self->config.factories) {
        // If the Factory has some transformations connected to it, then return true;
        if([self->destinationsWithTransformationsEnabled objectForKey:factory.key])
            return YES;
    }
    return NO;
}

- (BOOL) areFactoriesPassedInConfig {
    if(self->config == nil || self->config.factories == nil || self->config.factories.count == 0)
        return NO;
    return YES;
}

- (BOOL) areCustomFactoriesPassedInConfig {
    if(self->config == nil || self->config.customFactories == nil || self->config.customFactories.count == 0)
        return NO;
    return YES;
}

@end
