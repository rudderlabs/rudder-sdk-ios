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
#import "RSServerConfigManager.h"
#import "RSDBPersistentManager.h"
#import "UIViewController+RSScreen.h"
#import "RSApplicationLifeCycleManager.h"
#import "WKInterfaceController+RSScreen.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSEventRepository : NSObject {
    RSConfig* config;
    RSDBPersistentManager* dbpersistenceManager;
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
    NSLock* lock;
}

+ (instancetype) initiate: (NSString*) writeKey config: (RSConfig*) config;
+ (instancetype) getInstance;
- (void) setAnonymousIdToken;
- (void) updateCTSAuthToken;
- (void) dump:(RSMessage*) message;
- (void) reset;
- (void) flush;
- (BOOL) getOptStatus;
- (void) saveOptStatus: (BOOL) optStatus;

- (void) startSession:(long) sessionId;
- (void) endSession;

- (RSConfig* _Nullable) getConfig;
- (void) applicationDidFinishLaunchingWithOptions:(NSDictionary *) launchOptions;
@end

NS_ASSUME_NONNULL_END
