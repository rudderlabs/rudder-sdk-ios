//
//  EventRepository.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "RSUtils.h"
#import "RSConfig.h"
#import "RSLogger.h"
#import "RSMessage.h"
#import "RSFlushManager.h"
#import "RSElementCache.h"
#import "RSCloudModeManager.h"
#import "RSDeviceModeManager.h"
#import "RSPreferenceManager.h"
#import "RSDBPersistentManager.h"
#import "RSDataResidencyManager.h"
#import "RSServerConfigManager.h"
#import "RSDBPersistentManager.h"
#import "UIViewController+RSScreen.h"
#import "RSApplicationLifeCycleManager.h"
#import "RSEventFilteringPlugin.h"
#import "WKInterfaceController+RSScreen.h"
#import "RSConsentFilter.h"
#import "RSConsentFilterHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSEventRepository : NSObject {
    RSConfig* config;
    RSDBPersistentManager* dbpersistenceManager;
    RSDataResidencyManager* dataResidencyManager;
    RSServerConfigManager* configManager;
    RSNetworkManager* networkManager;
    RSPreferenceManager *preferenceManager;
    RSCloudModeManager *cloudModeManager;
    RSDeviceModeManager *deviceModeManager;
    RSFlushManager *flushManager;
    RSBackGroundModeManager *backGroundModeManager;
    RSApplicationLifeCycleManager *applicationLifeCycleManager;
    RSUserSession * userSession;
    BOOL isSDKInitialized;
    BOOL isSDKEnabled;
    NSString* writeKey;
    NSString* authToken;
    NSString* anonymousIdToken;
    NSMutableDictionary<NSString*, NSObject*>* integrations;
    RSConsentFilterHandler *consentFilterHandler;
    RSEventFilteringPlugin *eventFilteringPlugin;
    NSLock* lock;
    dispatch_source_t source;
    dispatch_queue_t repositoryQueue;
    RSClient *client;
    RSOption *defaultOptions;
}

+ (instancetype)initiate:(NSString*)writeKey config:(RSConfig*)config client:(RSClient *)client options:(RSOption * __nullable)options;
+ (instancetype) getInstance;
- (void) setAnonymousIdToken;
- (void) dump:(RSMessage*) message;
- (void) reset;
- (void) flush;
- (BOOL) getOptStatus;
- (void) saveOptStatus: (BOOL) optStatus;

- (void) startSession:(long) sessionId;
- (void) endSession;
- (NSNumber * _Nullable)getSessionId;

- (RSConfig* _Nullable) getConfig;
- (void)applicationDidFinishLaunchingWithOptions:(NSDictionary *) launchOptions;
- (void)applyIntegrations:(RSMessage *)message withDefaultOption:(RSOption *)defaultOption; // Added this method in header for testing purpose
- (RSMessage *)applyConsents:(RSMessage *)message; // Added this method in header for testing purpose
- (void)applySession:(RSMessage *)message withUserSession:(RSUserSession *)userSession andRudderConfig:(RSConfig *)rudderConfig; // Added this method in header for testing purpose
@end

NS_ASSUME_NONNULL_END
