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
#import "RSConsentFilter.h"
#import "RSConsentFilterHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSEventRepository : NSObject {
    NSString* writeKey;
    NSString* authToken;
    NSString* anonymousIdToken;
    NSString* dataPlaneUrl;
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
    RSConsentFilterHandler *consentFilterHandler;
    NSMutableArray *eventReplayMessage;
    RSPreferenceManager *preferenceManager;
    RSEventFilteringPlugin *eventFilteringPlugin;
    RSUserSession *userSession;
    BOOL firstForeGround;
    BOOL areFactoriesInitialized;
    BOOL isSemaphoreReleased;
    BOOL isSDKInitialized;
    BOOL isSDKEnabled;
    NSLock* lock;
    dispatch_source_t source;
    dispatch_queue_t queue;
    RSClient *client;
}

+ (instancetype)initiate:(NSString*)writeKey config:(RSConfig*)config client:(RSClient *)client;
- (void) setAnonymousIdToken;
- (void) dump:(RSMessage*) message;
- (void) reset;
- (void) flush;

- (BOOL) getOptStatus;
- (void) saveOptStatus: (BOOL) optStatus;

- (void) startSession:(long) sessionId;
- (void) endSession;

- (RSConfig* _Nullable) getConfig;
- (void)_applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void)applyIntegrations:(RSMessage *)message withDefaultOption:(RSOption *)defaultOption; // Added this method in header for testing purpose
- (RSMessage *)applyConsents:(RSMessage *)message; // Added this method in header for testing purpose
- (void)applySession:(RSMessage *)message withUserSession:(RSUserSession *)userSession andRudderConfig:(RSConfig *)rudderConfig; // Added this method in header for testing purpose

@end

NS_ASSUME_NONNULL_END
