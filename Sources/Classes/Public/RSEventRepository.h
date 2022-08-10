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
#import "RSBackGroundModeManager.h"
#import "RSApplicationLifeCycleManager.h"
#import "RSFlushManager.h"
#import "RSCloudModeManager.h"
#import "RSDeviceModeManager.h"
#import "RSElementCache.h"
#import "RSUtils.h"
#import "RSLogger.h"
#import "WKInterfaceController+RSScreen.h"
#import "UIViewController+RSScreen.h"


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
- (void) dump:(RSMessage*) message;
- (void) reset;
- (void) flush;
- (BOOL) getOptStatus;
- (void) saveOptStatus: (BOOL) optStatus;
- (RSConfig* _Nullable) getConfig;
- (void) applicationDidFinishLaunchingWithOptions:(NSDictionary *) launchOptions;
@end

NS_ASSUME_NONNULL_END
