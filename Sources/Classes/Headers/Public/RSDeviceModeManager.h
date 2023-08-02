//
//  RSDeviceModeManager.h
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSServerConfigSource.h"
#import "RSEventFilteringPlugin.h"
#import "RSDBPersistentManager.h"
#import "RSNetworkManager.h"
#import "RSConsentFilterHandler.h"
#import "RSServerConfigManager.h"
#import "RSTransformationEvent.h"
#import "RSTransformationRequest.h"

@interface RSDeviceModeManager : NSObject {
    RSConfig *config;
    RSDBPersistentManager *dbPersistentManager;
    RSNetworkManager *networkManager;
    RSEventFilteringPlugin *eventFilteringPlugin;
    NSMutableArray<NSString *>* consentedDestinationNames;
    NSMutableDictionary<NSString*, id<RSIntegration>>* integrationOperationMap;
    NSMutableDictionary<NSString*, NSString*>* destinationsWithTransformationsEnabled;
    NSMutableArray<NSString*>* destinationsAcceptingEventsOnTransformationError;
    BOOL areFactoriesInitialized;
    BOOL isDeviceModeFactoriesNotPresent;
}

- (instancetype) initWithConfig:(RSConfig *) config andDBPersistentManager:(RSDBPersistentManager *)dbPersistentManager andNetworkManager:(RSNetworkManager *)networkManager;
- (void) startDeviceModeProcessor:(NSArray<RSServerDestination*>*) consentedDestinations withConfigManager:(RSServerConfigManager *) configManager;
- (void) makeFactoryDump:(RSMessage *)message FromHistory:(BOOL) fromHistory withRowId:(NSNumber *) rowId;
- (void) dumpOriginalEventsOnTransformationError:(NSArray<RSTransformationEvent*>*) transformationEvents;
- (void) dumpOriginalEventsOnTransformationsFeatureDisabled:(NSArray<RSTransformationEvent*>*) transformationEvents;
-(void) dumpTransformedEvents:(NSArray*) transformedPayloads toDestinationId:(NSString*) destinationId whereOriginalPayload:(RSTransformationRequest*) request;
- (NSArray<NSString *> *) getDestinationIdsWithTransformationStatus:(TRANSFORMATION_STATUS) status fromMessage:(RSMessage *) message;
- (void) reset;
- (void) flush;
- (void) handleCaseWhenNoDeviceModeFactoryIsPresent;

@end
