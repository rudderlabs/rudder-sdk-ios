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

@interface RSDeviceModeManager : NSObject {
    RSConfig *config;
    RSDBPersistentManager *dbPersistentManager;
    RSNetworkManager *networkManager;
    RSEventFilteringPlugin *eventFilteringPlugin;
    RSConsentFilterHandler *consentFilterHandler;
    NSMutableDictionary<NSString*, id<RSIntegration>>* integrationOperationMap;
    NSDictionary<NSString*, NSString*>* destinationsWithTransformationsEnabled;
    BOOL areFactoriesInitialized;
    long beforeSDKInitEventTimestamp;
}

- (instancetype) initWithConfig:(RSConfig *) config andDBPersistentManager:(RSDBPersistentManager *)dbPersistentManager andNetworkManager:(RSNetworkManager *)networkManager;
- (void) sendPreviousUnprocessedDeviceModeEvents;
- (long) getFirstEventTimestampBeforeSDKInit;
- (void) startDeviceModeProcessor:(NSArray<RSServerDestination*>*) destinations andDestinationsWithTransformationsEnabled: (NSDictionary<NSString*, NSString*>*) destinationsWithTransformationsEnabled;
- (void) makeFactoryDump:(RSMessage *)message FromHistory:(BOOL) fromHistory withRowId:(NSNumber *) rowId;
- (void) dumpOriginalEvents:(NSArray *) originalPayloads;
- (void) dumpTransformedEvents:(NSArray*) transformedPayloads toDestinationId:(NSString*) destinationId;
- (void) reset;
- (void) flush;

@end
