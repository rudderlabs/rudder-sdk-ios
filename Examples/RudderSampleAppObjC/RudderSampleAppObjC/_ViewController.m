//
//  _ViewController.m
//  Rudder
//
//  Created by arnabp92 on 02/26/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

#import "_ViewController.h"
#import "_AppDelegate.h"
#import <Rudder/Rudder.h>

@interface _ViewController ()

@end

@implementation _ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    [[RSClient sharedInstance] identify:@"test_user_id" traits:@{
//        @"firstName": @"Test",
//        @"lastName": @"Name",
//        @"email": @"test_1@gmail.com",
//        @"phone": @"+91-986543210",
//        @"company": @{
//                @"id": @"test_company_id",
//                @"name": @"Test Company",
//                @"industry": @"Test Industry",
//                @"address": @"Test Location"
//        }
//    }];
//
//    [[RSClient sharedInstance] alias:@"some_other_id"];
//
//    [[RSClient sharedInstance] track:@"test_event_2" properties:@{
//        @"string_key_1": @"string_value",
//        @"string_key_2": @"string_value",
//        @"string_key_3": @"string_value",
//        @"string_key_4": @"string_value",
//        @"bool_key": @YES,
//        @"num_key": @1.2,
//        @"dict_key": @{
//                @"c_key_1": @"value_1",
//                @"c_key_2": @"value_2"
//        }
//    }];
    
//    RSOption *options = [[RSOption alloc] init];
//    [options putExternalId:@"test" withId:@"test"];
//    [[RSClient sharedInstance] screen:@"ViewController"];
//    [[RSClient sharedInstance] screen:@"Main screen name" properties:@{@"prop_key" : @"prop_value"}];
//    [[RSClient sharedInstance] screen:@"test screen" properties:@{@"prop_key" : @"prop_value"} options:options];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//    NSMutableDictionary *traits = [[NSMutableDictionary alloc] initWithDictionary:@{
//        @"firstName": @"Test",
//        @"lastName": @"Name",
//        @"email": @"test_1@gmail.com",
//        @"phone": @"+91-986543210",
//        @"company": @{
//            @"id": @"test_company_id",
//            @"name": @"Test Company",
//            @"industry": @"Test Industry",
//            @"address": @"Test Location"
//        },
//        @"user_id": [NSNull null]
//    }];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//    [[RSClient sharedInstance] identify:@"test_user_id" traits:@{}];
//    });
        
//    [traits removeAllObjects];
//    [traits setValue:@"Kolkata" forKey:@"address"];
//    });
    
    
}
- (IBAction)track:(id)sender {
    [_AppDelegate track];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
