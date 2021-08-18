//
//  AppDelegate.m
//  PodTesting
//
//  Created by Desu Sai Venkat on 28/07/21.
//

#import "_AppDelegate.h"
#import <Rudder/Rudder.h>

@interface _AppDelegate ()

@end

@implementation _AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
    [builder withDataPlaneUrl:@"https://7b346d91ee24.ngrok.io"];
    [RSClient getInstance:@"1pcZviVxgjd3rTUUmaTUBinGH0A" config:[builder build]];
    
    
//            [[RSClient sharedInstance] identify:@"test_user_id"
//                                         traits:@{@"foo": @"bar",
//                                                  @"foo1": @"bar1",
//                                                  @"email": @"test@gmail.com",
//                                                  @"key_1" : @"value_1",
//                                                  @"key_2" : @"value_2"
//                                         }
//            ];

    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(int i=0;i<100000;i++)
        {
            NSLog(@"Thread 1 and identify call %d",i);
        [[RSClient sharedInstance] identify:@"test_user_id"
                                     traits:@{@"foo": @"bar",
                                              @"foo1": @"bar1",
                                              @"email": @"test@gmail.com",
                                              @"key_1" : @"value_1",
                                              @"key_2" : @"value_2"
                                     }
        ];
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(int i=0;i<100000;i++)
        {
            NSLog(@"Thread 2 and identify call %d",i);
        [[RSClient sharedInstance] identify:@"test_user_id"
                                     traits:@{@"foo": @"bar",
                                              @"foo1": @"bar1",
                                              @"email": @"test@gmail.com",
                                              @"key_1" : @"value_1",
                                              @"key_2" : @"value_2"
                                     }
        ];
        }
    });
    for(int i=0;i<100000;i++)
    {
        NSLog(@"Main Thread and identify call %d",i);
    [[RSClient sharedInstance] identify:@"test_user_id"
                                 traits:@{@"foo": @"bar",
                                          @"foo1": @"bar1",
                                          @"email": @"test@gmail.com",
                                          @"key_1" : @"value_1",
                                          @"key_2" : @"value_2"
                                 }
    ];
    }
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for(int i=0;i<100000;i++)
//        {
//            NSLog(@"Thread 3 and identify call %d",i);
//        [[RSClient sharedInstance] identify:@"test_user_id"
//                                     traits:@{@"foo": @"bar",
//                                              @"foo1": @"bar1",
//                                              @"email": @"test@gmail.com",
//                                              @"key_1" : @"value_1",
//                                              @"key_2" : @"value_2"
//                                     }
//        ];
//        }
//    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for(int i=0;i<100000;i++)
//        {
//            NSLog(@"Thread 4 and identify call %d",i);
//        [[RSClient sharedInstance] identify:@"test_user_id"
//                                     traits:@{@"foo": @"bar",
//                                              @"foo1": @"bar1",
//                                              @"email": @"test@gmail.com",
//                                              @"key_1" : @"value_1",
//                                              @"key_2" : @"value_2"
//                                     }
//        ];
//        }
//    }); dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for(int i=0;i<100000;i++)
//        {
//            NSLog(@"Thread 5 and identify call %d",i);
//        [[RSClient sharedInstance] identify:@"test_user_id"
//                                     traits:@{@"foo": @"bar",
//                                              @"foo1": @"bar1",
//                                              @"email": @"test@gmail.com",
//                                              @"key_1" : @"value_1",
//                                              @"key_2" : @"value_2"
//                                     }
//        ];
//        }
//    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for(int i=0;i<100000;i++)
//        {
//            NSLog(@"Thread 6 and identify call %d",i);
//        [[RSClient sharedInstance] identify:@"test_user_id"
//                                     traits:@{@"foo": @"bar",
//                                              @"foo1": @"bar1",
//                                              @"email": @"test@gmail.com",
//                                              @"key_1" : @"value_1",
//                                              @"key_2" : @"value_2"
//                                     }
//        ];
//        }
//    });
    
    NSLog(@"Main Thread");
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
