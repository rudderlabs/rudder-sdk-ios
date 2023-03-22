//
//  RSCloudModeManager.h
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSDBPersistentManager.h"
#import "RSNetworkManager.h"
#import "RSEnums.h"

@interface RSCloudModeManager : NSObject {
    RSDBPersistentManager* dbPersistentManager;
    RSNetworkManager* networkManager;
    RSConfig* config;
    NSLock* lock;
    dispatch_queue_t cloud_mode_processor_queue;
}

- (instancetype)initWithConfig:(RSConfig *) config andDBPersistentManager:(RSDBPersistentManager *) dbPersistentManager andNetworkManager:(RSNetworkManager *) networkManager andLock: (NSLock *) lock;
- (void) startCloudModeProcessor;
+ (NSString*) getPayloadFromMessages: (RSDBMessage*)dbMessage;

@end
