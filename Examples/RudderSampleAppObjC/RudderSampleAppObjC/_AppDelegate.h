//
//  _AppDelegate.h
//  Rudder
//
//  Created by arnabp92 on 02/26/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

@import UIKit;
@import UserNotifications;
@import FirebaseCore;
@import FirebaseMessaging;

@interface _AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (void) sendIdentify;
+ (void) sendTrack;
+ (void) sendScreen;
+ (void) sendGroup;
+ (void) sendAlias;
+ (void) sendReset;

@end
