//
//  RSDeviceModeTransformationManager.h
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSLogger.h"
#import "RSConfig.h"
#import "RSNetworkManager.h"
#import "RSEnums.h"
#import "RSDeviceModeManager.h"
#import "RSDBPersistentManager.h"
#import "RSTransformationRequest.h"
#import "RSTransformationMetadata.h"



@interface RSDeviceModeTransformationManager : NSObject {
    RSConfig* config;
    RSDBPersistentManager* dbPersistentManager;
    RSNetworkManager* networkManager;
    RSDeviceModeManager* deviceModeManager;
}

- (instancetype)initWithConfig:(RSConfig *) config andDBPersistentManager:(RSDBPersistentManager *) dbPersistentManager andDeviceModeManager:(RSDeviceModeManager *) deviceModeManager andNetworkManager:(RSNetworkManager *) networkManager;
- (void) startTransformationProcessor;

@end
