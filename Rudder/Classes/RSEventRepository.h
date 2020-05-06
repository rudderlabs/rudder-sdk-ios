//
//  EventRepository.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSMessage.h"
#import "RSServerConfigManager.h"
#import "RSDBPersistentManager.h"
#import "RSConfig.h"
#import "RSPreferenceManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSEventRepository : NSObject {
    NSString* writeKey;
    NSString* authToken;
    NSString* anonymousIdToken;
    RSConfig* config;
    RSDBPersistentManager* dbpersistenceManager;
    RSServerConfigManager* configManager;
    NSMutableDictionary<NSString*, NSObject*>* integrations;
    NSMutableDictionary<NSString*, id<RSIntegration>>* integrationOperationMap;
    NSMutableArray *eventReplayMessage;
    RSPreferenceManager *preferenceManager;
    BOOL isFactoryInitialized;
    BOOL isSDKInitialized;
    BOOL isSDKEnabled;
}

+ (instancetype) initiate: (NSString*) writeKey config: (RSConfig*) config;
- (void) dump:(RSMessage*) message;
- (void) reset;
- (RSConfig* _Nullable) getConfig;

@end

NS_ASSUME_NONNULL_END
