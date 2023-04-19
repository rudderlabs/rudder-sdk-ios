//
//  RSFlushManager.h
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSNetworkManager.h"
#import "RSDBPersistentManager.h"
#import "RSCloudModeManager.h"

@interface RSFlushManager : NSObject {
    RSNetworkManager* networkManager;
    RSDBPersistentManager* dbPersistentManager;
    RSConfig* config;
    NSLock* lock;
    dispatch_source_t source;
    dispatch_queue_t queue;
}

- (void) flush;
- (void) setUpFlush;
- (instancetype)initWithConfig:(RSConfig *)config andPersistentManager:(RSDBPersistentManager *)dbPersistentManager andNetworkManager:(RSNetworkManager *) networkManager andLock:(NSLock *) lock;
@end
