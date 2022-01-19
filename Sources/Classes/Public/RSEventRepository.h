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
#import "RSEventFilteringPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSEventRepository : NSObject {
    NSString* writeKey;
    NSString* authToken;
    NSString* anonymousIdToken;
    RSConfig* config;
#if !TARGET_OS_WATCH
    UIBackgroundTaskIdentifier backgroundTask;
#else
    dispatch_semaphore_t semaphore;
#endif
    RSDBPersistentManager* dbpersistenceManager;
    RSServerConfigManager* configManager;
    NSMutableDictionary<NSString*, NSObject*>* integrations;
    NSMutableDictionary<NSString*, id<RSIntegration>>* integrationOperationMap;
    NSMutableArray *eventReplayMessage;
    RSPreferenceManager *preferenceManager;
    RSEventFilteringPlugin *eventFilteringPlugin;
    BOOL firstForeGround;
    BOOL areFactoriesInitialized;
    BOOL isSemaphoreReleased;
    BOOL isSDKInitialized;
    BOOL isSDKEnabled;
}

+ (instancetype) initiate: (NSString*) writeKey config: (RSConfig*) config;
- (void) setAnonymousIdToken;
- (void) dump:(RSMessage*) message;
- (void) reset;
- (void) flush;

- (BOOL) getOptStatus;
- (void) saveOptStatus: (BOOL) optStatus;

- (RSConfig* _Nullable) getConfig;
- (void)_applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END
