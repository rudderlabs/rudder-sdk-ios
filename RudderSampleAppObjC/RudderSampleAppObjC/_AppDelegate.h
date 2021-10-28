//
//  _AppDelegate.h
//  Rudder
//
//  Created by arnabp92 on 02/26/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

@import UIKit;
@import UserNotifications;
@import Firebase;
@import FirebaseMessaging;

@interface _AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, FIRMessagingDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
