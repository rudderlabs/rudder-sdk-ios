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

@interface RSDeviceModeManager : NSObject {
    RSConfig *config;
    RSServerConfigSource *serverConfig;
    RSDBPersistentManager *dbPersistentManager;
    RSNetworkManager *networkManager;
    RSEventFilteringPlugin *eventFilteringPlugin;
    NSMutableDictionary<NSString*, id<RSIntegration>>* integrationOperationMap;
    NSMutableArray<RSMessage*> *eventReplayMessage;
    NSDictionary<NSString*, NSString*>* destinationsWithTransformationsEnabled;
    BOOL areFactoriesInitialized;
}

- (instancetype)initWithConfig:(RSConfig *) config andDBPersistentManager:(RSDBPersistentManager *)dbPersistentManager andNetworkManager:(RSNetworkManager *)networkManager;
- (void) startDeviceModeProcessor:(RSServerConfigSource *) serverConfig andDestinationsWithTransformationsEnabled: (NSDictionary<NSString*, NSString*>*) destinationsWithTransformationsEnabled;
- (void) makeFactoryDump:(RSMessage *)message FromHistory:(BOOL) fromHistory;
-(void) dumpTransformedEvents:(NSArray*) transformedPayloads ToDestination:(NSString*) destinationId;
- (void)reset;
- (void)flush;

@end
