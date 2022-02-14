//
//  _ViewController.m
//  Rudder
//
//  Created by arnabp92 on 02/26/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

#import "_ViewController.h"
#import <Rudder/Rudder.h>
#import "_AppDelegate.h"

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)identifyDifferentExternalId:(id)sender {
    
    RSOption *identifyOptions = [[RSOption alloc] init];
    [identifyOptions putExternalId:@"brazeExternalId-6" withId:@"some_external_id   20"];
    
    [identifyOptions putExternalId:@"brazeExternalId-6" withId:@"some_external_id   22"];
//    [identifyOptions putExternalId:@"brazeExternalId-3" withId:@"some_external_id_2"];
//    [identifyOptions putExternalId:@"brazeExternalId-4" withId:@"some_external_id_3"];
    [[RSClient sharedInstance] identify:@"testUserId"
                                 traits:@{@"firstname": @"First Name"}
                                options:identifyOptions];
    
    
}


- (IBAction)track:(id)sender {
//    [[RSClient sharedInstance] track:@"Track"];
    
    [_AppDelegate makeEvents:0];
    
//    RSOption *identifyOptions = [[RSOption alloc] init];
//    [identifyOptions putExternalId:@"brazeExternalId-5" withId:@"some_external_id   10"];
    
//    [identifyOptions putExternalId:@"brazeExternalId-5" withId:@"some_external_id   11"];
//    [identifyOptions putExternalId:@"brazeExternalId-3" withId:@"some_external_id_2"];
//    [identifyOptions putExternalId:@"brazeExternalId-4" withId:@"some_external_id_3"];
//    [[RSClient sharedInstance] identify:@"testUserId"
//                                 traits:@{@"firstname": @"First Name"}
//                                options:identifyOptions];
    
}
- (IBAction)reset:(id)sender {
    [[RSClient sharedInstance] reset];
}

- (IBAction)manageThreads:(id)sender {
    [_AppDelegate manageThread];
}


@end
