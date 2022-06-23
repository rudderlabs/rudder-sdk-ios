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

typedef enum {
    BATCH_ENDPOINT = 0,
    TRANSFORM_ENDPOINT = 1
} ENDPOINT;

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
    NSMutableDictionary<NSNumber*, RSMessage*> *eventReplayMessage;
    NSDictionary<NSString*, NSString*>* destinationsWithTransformationsEnabled;
    RSPreferenceManager *preferenceManager;
    RSEventFilteringPlugin *eventFilteringPlugin;
    BOOL firstForeGround;
    BOOL areFactoriesInitialized;
    BOOL isSemaphoreReleased;
    BOOL isSDKInitialized;
    BOOL isSDKEnabled;
    NSLock* lock;
    dispatch_source_t source;
    dispatch_queue_t queue;
}

+ (instancetype) initiate: (NSString*) writeKey config: (RSConfig*) config;
+ (instancetype) getInstance;
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
