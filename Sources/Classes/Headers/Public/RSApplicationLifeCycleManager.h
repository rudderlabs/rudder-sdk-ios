//
//  RSApplicationLifeCycleManager.h
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSPreferenceManager.h"
#import "RSBackGroundModeManager.h"
#import "RSUtils.h"

@interface RSApplicationLifeCycleManager : NSObject {
    RSPreferenceManager* preferenceManager;
    RSBackGroundModeManager* backGroundModeManager;
    RSUserSession* userSession;
    RSConfig* config;
    BOOL firstForeGround;
}

- (instancetype)initWithConfig:(RSConfig*) config andPreferenceManager:(RSPreferenceManager*) preferenceManager andBackGroundModeManager:(RSBackGroundModeManager *) backGroundModeManager andUserSession:(RSUserSession *) userSession;
- (void) applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void) trackApplicationLifeCycle;
- (void) prepareScreenRecorder;

@end
