//
//  AppDelegate.h
//  RudderSampleApplication
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RudderSDKCore.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) RudderClient *_rudderClient;


@end

