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
#import "RSMetricsReporter.h"

@implementation RSDeviceModeManager

- (instancetype)initWithConfig:(RSConfig *) config andDBPersistentManager:(RSDBPersistentManager *)dbPersistentManager andNetworkManager:(RSNetworkManager *)networkManager {
    self = [super init];
    if(self) {
        self->config = config;
        self->dbPersistentManager = dbPersistentManager;
        self->networkManager = networkManager;
        self->integrationOperationMap = [[NSMutableDictionary alloc] init];
        self->destinationsWithTransformationsEnabled = [[NSMutableDictionary alloc] init];
        self->destinationsAcceptingEventsOnTransformationError = [[NSMutableArray alloc] init];
        self->consentedDestinationNames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) startDeviceModeProcessor:(NSArray<RSServerDestination*>*) consentedDestinations withConfigManager:(RSServerConfigManager *) configManager {
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Starting the Device Mode Processor"];
    [self segregateDestinations:consentedDestinations withConfigManager:configManager];
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Initializing the Event Filtering Plugin"];
    self->eventFilteringPlugin = [[RSEventFilteringPlugin alloc] init:consentedDestinations];
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Initializing the Device Mode Factories"];
    [self initiateFactories:consentedDestinations];
    // this might fail if serverConfig is nil, need to handle
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Initializing the Custom Factories"];
    [self initiateCustomFactories];
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

- (void)segregateDestinations:(NSArray<RSServerDestination*>*)consentedDestinations withConfigManager:(RSServerConfigManager *)configManager {
    
    // storing the display names of the destinations for which consent has been granted
    for(RSServerDestination* destination in consentedDestinations) {
        [self->consentedDestinationNames addObject:destination.destinationDefinition.displayName];
    }
    
    // filtering out destinations for which consent has been denied from destinationsWithTransformationsEnabled dict
    NSDictionary<NSString*, NSString*>* inputDestinationsWithTransformationsEnabled = [configManager getDestinationsWithTransformationsEnabled];
    for(NSString* key in [inputDestinationsWithTransformationsEnabled allKeys]) {
        if([self->consentedDestinationNames containsObject:key]){
            self->destinationsWithTransformationsEnabled[key] = inputDestinationsWithTransformationsEnabled[key];
        }
    }
    
    // filtering out destinations for which consent has been denied from destinationsAcceptingEventsOnTransformationError array
    NSArray<NSString*>* inputDestinationsAcceptingEventsOnTransformationError = [configManager getDestinationsAcceptingEventsOnTransformationError];
    for(NSString* destination in inputDestinationsAcceptingEventsOnTransformationError) {
        if([self->consentedDestinationNames containsObject:destination]){
            [self->destinationsAcceptingEventsOnTransformationError addObject:destination];
        }
    }
}

- (void) handleCaseWhenNoDeviceModeFactoryIsPresent {
    self->isDeviceModeFactoriesNotPresent = YES;
    [self replayMessageQueue];
}

- (void) initiateFactories : (NSArray*) destinations {
    if (![self areFactoriesPassedInConfig]) {
        [RSLogger logInfo:@"RSDeviceModeManager: initiateFactories: No native SDK is found in the config"];
        self->isDeviceModeFactoriesNotPresent = YES;
        return;
    }
    if (destinations.count == 0) {
        [RSLogger logInfo:@"RSDeviceModeManager: initiateFactories: No native SDK factory is found in the server config"];
        self->isDeviceModeFactoriesNotPresent = YES;
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
        if (destination == nil) {
            continue;
        }
        if (destination.isDestinationEnabled == YES) {
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
        } else {
            [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: initiateFactories: %@ factory is disabled", factory.key]];
            [RSMetricsReporter report:SDKMETRICS_DM_DISCARD forMetricType:COUNT withProperties:@{SDKMETRICS_TYPE: SDKMETRICS_DM_DISABLED, SDKMETRICS_INTEGRATION: destination.destinationDefinition.displayName} andValue:1];
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
    [RSLogger logDebug:@"RSDeviceModeManager: DeviceModeProcessor: Replaying the message queue to the Factories"];
    do {
        RSDBMessage *dbMessage = [self->dbPersistentManager fetchDeviceModeWithProcessedPendingEventsFromDb:RSFlushQueueSize];
        NSArray *messageIds = dbMessage.messageIds;
        NSArray *messages = dbMessage.messages;
        for (int i=0; i<messageIds.count; i++) {
            id object = [RSUtils deSerializeJSONString:messages[i]];
            NSNumber *rowId = [NSNumber numberWithInt:[messageIds[i] intValue]];
            if (object && rowId) {
                RSMessage* originalMessage = [[RSMessage alloc] initWithDict:object];
                [self makeFactoryDump:originalMessage FromHistory:YES withRowId:rowId];
            }
        }
    } while([self->dbPersistentManager getDeviceModeWithProcessedPendingEventsRecordCount] > 0);
}

- (void) makeFactoryDump:(RSMessage *)message FromHistory:(BOOL) fromHistory withRowId:(NSNumber *) rowId {
    @synchronized (self) {
        if (self->isDeviceModeFactoriesNotPresent) {
            [self markDeviceModeTransformationDone:rowId andEvent:message.event];
        } else if (self->areFactoriesInitialized || fromHistory) {
            [RSLogger logVerbose:@"RSDeviceModeManager: makeFactoryDump: dumping message to native sdk factories"];
            NSArray<NSString *>* eligibleDestinations = [self getEligibleDestinations:message];
            [self updateMessageStatusBasedOnTransformations:eligibleDestinations andRowId:rowId andMessage:message];
            [self dumpMessageToDestinationWithoutTransformation:eligibleDestinations andMessage:message];
        }
    }
}

-(void) markDeviceModeTransformationDone:(NSNumber *) rowId andEvent:(NSString *) event {
    [RSLogger logDebug: [[NSString alloc] initWithFormat:@"RSDeviceModeManager: markDeviceModeTransformationDone: Marking message %@ as DEVICE_MODE_DONE and DM_PROCESSED_DONE", event]];
    [self->dbPersistentManager markDeviceModeTransformationAndProcessedDone:rowId];
}

-(void) updateMessageStatusBasedOnTransformations:(NSArray<NSString *>*)eligibleDestinations andRowId:(NSNumber *)rowId andMessage:(RSMessage *)message {
    NSArray<NSString *>* destinationsWithTransformations = [self getDestinationsWithTransformationStatus:ENABLED fromDestinations:eligibleDestinations];
    if(destinationsWithTransformations.count == 0){
        [self markDeviceModeTransformationDone:rowId andEvent:message.event];
    } else {
        for (NSString * destination in destinationsWithTransformations) {
            [RSLogger logDebug: [[NSString alloc] initWithFormat:@"RSDeviceModeManager: updateMessageStatusBasedOnTransformations: Device Mode Destination %@ needs transformation hence it will be batched and sent to the transformation service", destination]];
        }
        [self->dbPersistentManager markDeviceModeProcessedDone:rowId];
        [RSLogger logDebug: [[NSString alloc] initWithFormat:@"RSDeviceModeManager: updateMessageStatusBasedOnTransformations: Marking event: %@, dm_processed as DM_PROCESSED_DONE", message.event]];
    }
}

-(void) dumpMessageToDestinationWithoutTransformation:(NSArray<NSString *>*)eligibleDestinations andMessage:(RSMessage *)message {
    NSArray<NSString *>* destinationsWithoutTransformations = [self getDestinationsWithTransformationStatus:DISABLED fromDestinations:eligibleDestinations];
    [self dumpEvent:message toDestinations:destinationsWithoutTransformations withLogTag:@"makeFactoryDump"];
}

- (void) dumpOriginalEventsOnTransformationError:(NSArray<RSTransformationEvent*>*) transformationEvents {
    for(RSTransformationEvent* transformationEvent in transformationEvents) {
        RSMessage* originalMessage = transformationEvent.event;
        NSArray<NSString *> * destinationNames = [self getDestinationNamesForIds:transformationEvent.destinationIds];
        for(NSString* destinationName in destinationNames) {
            if(![self->destinationsAcceptingEventsOnTransformationError containsObject:destinationName]) {
                [RSLogger logWarn:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: dumpOriginalEventsOnTransformationError: Destination %@ is not configured to accept events on transformation error, hence dropping the %@ event %@", destinationName, originalMessage.type, originalMessage.event]];
                continue;
            }
            [self dumpEvent:originalMessage toDestinations:@[destinationName] withLogTag:@"dumpOriginalEventsOnTransformationError"];
        }
    }
}

- (void) dumpOriginalEventsOnTransformationsFeatureDisabled:(NSArray<RSTransformationEvent*>*) transformationEvents {
    [RSLogger logWarn:@"RSDeviceModeManager: dumpOriginalEvents: Transformation Feature is not enabled, hence dumping back the original events to transformation enabled destinations"];
    for(RSTransformationEvent* transformationEvent in transformationEvents) {
        RSMessage* originalMessage = transformationEvent.event;
        NSArray<NSString *> * destinationNames = [self getDestinationNamesForIds:transformationEvent.destinationIds];
        [self dumpEvent:originalMessage toDestinations:destinationNames withLogTag:@"dumpOriginalEventsOnTransformationsFeatureDisabled"];
        continue;
    }
}

- (RSMessage *)getOriginalEventWith:(NSNumber *)orderNo FromRequest:(RSTransformationRequest *)request {
    RSMessage* originalMessage = nil;
    for(RSTransformationEvent* transformationEvent in request.batch) {
        if(transformationEvent.orderNo == orderNo) {
            originalMessage = transformationEvent.event;
            return originalMessage;
        }
    }
    return originalMessage;
}

-(void) dumpTransformedEvents:(NSArray*) transformedPayloads toDestinationId:(NSString*) destinationId whereOriginalPayload:(RSTransformationRequest*) request {
    NSString* destinationName = [self->destinationsWithTransformationsEnabled allKeysForObject:destinationId][0];
    if(destinationName == nil)
        return;
    [RSLogger logDebug: [[NSString alloc] initWithFormat:@"RSDeviceModeManager: dumpTransformedEvents: Dumping back the transformed events to the destination %@", destinationName]];
    for (NSDictionary* transformedPayload in transformedPayloads) {
        NSString* status = transformedPayload[@"status"];
        if(status == nil) continue;
        if([status isEqualToString:@"200"]) {
            NSDictionary* event = transformedPayload[@"event"];
            if(event == nil) {
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: dumpTransformedEvents: User Dropped an event for the destination %@ in the transformation service hence ignoring it", destinationName]];
                continue;
            }
            RSMessage* transformedMessage = [[RSMessage alloc] initWithDict:transformedPayload[@"event"]];
            [self dumpEvent:transformedMessage toDestinations:@[destinationName] withLogTag:@"dumpTransformedEvents"];
            continue;
        }
        NSNumber* orderNo = [NSNumber numberWithInt:[transformedPayload[@"orderNo"] intValue]];
        RSMessage * originalMessage = [self getOriginalEventWith:orderNo FromRequest:request];
        if(originalMessage == nil) continue;
        [RSLogger logWarn: [[NSString alloc] initWithFormat:@"RSDeviceModeManager: dumpTransformedEvents: Transformation of %@ event %@ for destination %@ has failed %@", originalMessage.type, originalMessage.event, destinationName, [status isEqualToString:@"410"] ? @"as its configuration has been modified or the transformation is disabled": @""]];
        if(![self->destinationsAcceptingEventsOnTransformationError containsObject:destinationName]) {
            [RSLogger logWarn:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: dumpTransformedEvents: Destination %@ is not accepting events on transformation error, hence dropping the %@ event %@", destinationName, originalMessage.type, originalMessage.event]];
            continue;
        }
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: dumpTransformedEvents: Destination %@ is accepting events on transformation error, hence dumping the original event to it.", destinationName]];
        [self dumpEvent:originalMessage toDestinations:@[destinationName] withLogTag:@"dumpOriginalEvents"];
    }
    
}

-(void) dumpEvent:(RSMessage *) message toDestinations:(NSArray<NSString *> *) destinations withLogTag:(NSString *) logTag {
    for(NSString* destination in destinations) {
        id<RSIntegration> integration = [self->integrationOperationMap objectForKey:destination];
        if(integration != nil) {
            @try {
                [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSDeviceModeManager: %@: dumping event %@ to factory %@", logTag, message.event, destination]];
                [integration dump:message];
                [RSMetricsReporter report:SDKMETRICS_DM_EVENT forMetricType:COUNT withProperties:@{SDKMETRICS_TYPE: message.type, SDKMETRICS_INTEGRATION: destination} andValue:1];
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

- (BOOL) isEvent:(RSMessage *) message allowedForDestination: (NSString *) destinationName {
    BOOL isDestinationEnabledInMessage = [self isDestination:destinationName enabledInMessage:message];
    BOOL isEventAllowedByDestination = [self->eventFilteringPlugin isEventAllowed:message byDestination:destinationName];
    return isDestinationEnabledInMessage && isEventAllowedByDestination;
}

- (BOOL) isDestination:(NSString *) destinationName enabledInMessage:(RSMessage *) message {
    NSDictionary<NSString*, NSObject*>*  integrationOptions = message.integrations;
    // If All is set to true and the destination is absent in the integrations object
    BOOL isAllTrueAndDestinationAbsent = [(NSNumber*)integrationOptions[@"All"] boolValue] && (integrationOptions[destinationName]==nil);
    // If the destination is present and true in the integrations object
    BOOL isDestinationEnabled = [(NSNumber*)integrationOptions[destinationName] boolValue];
    return isAllTrueAndDestinationAbsent || isDestinationEnabled;
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

- (NSArray<NSString *> *) getDestinationIdsWithTransformationStatus:(TRANSFORMATION_STATUS) status fromMessage:(RSMessage *) message {
    NSArray<NSString *>* eligibleDestinations = [self getEligibleDestinations:message];
    NSArray<NSString*>* destinationNames = [self getDestinationsWithTransformationStatus:status fromDestinations:eligibleDestinations];
    NSMutableArray<NSString*>* destinationIds = [[NSMutableArray alloc] init];
    for(NSString* destinationName in destinationNames) {
        NSString* destinationId = self->destinationsWithTransformationsEnabled[destinationName];
        if( destinationId!= nil) {
            [destinationIds addObject: destinationId];
        }
    }
    return destinationIds;
}

- (NSArray<NSString*>*) getDestinationsAcceptingEventsOnTransformationError:(NSArray<NSString*>*) destinations {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self->destinationsAcceptingEventsOnTransformationError];
    NSArray *acceptingDestinations = [destinations filteredArrayUsingPredicate:predicate];
    return acceptingDestinations;
}

- (NSArray<NSString*>*) getDestinationNamesForIds:(NSArray<NSString*>*) destinationIds {
    NSMutableArray<NSString*>* destinationNames = [[NSMutableArray alloc] init];
    for(NSString* destinationId in destinationIds) {
        NSString* destinationName = [self->destinationsWithTransformationsEnabled allKeysForObject:destinationId][0];
        if(destinationName != nil) {
            [destinationNames addObject:destinationName];
        }
    }
    return destinationNames;
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
