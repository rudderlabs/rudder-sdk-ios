//
//  _AppDelegate.h
//  Rudder
//
//  Created by arnabp92 on 02/26/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

@import UIKit;
@import UserNotifications;

@interface _AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (void) initializeSDK;
+ (void) sendIdentify;
+ (void) sendTrack;
+ (void) sendScreen;
+ (void) sendGroup;
+ (void) sendAlias;
+ (void) sendReset;
+ (void) putAdvertisingId;
+ (void) clearAdvertisingId;

@end
