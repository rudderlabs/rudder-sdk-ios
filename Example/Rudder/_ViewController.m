//
//  _ViewController.m
//  Rudder
//
//  Created by arnabp92 on 02/26/2020.
//  Copyright (c) 2020 arnabp92. All rights reserved.
//

#import "_ViewController.h"
#import <Rudder/Rudder.h>

@interface _ViewController ()

@end

@implementation _ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    
   [[RSClient sharedInstance] track:@"simple_track_event"];
    [[RSClient sharedInstance] track:@"simple_track_with_props" properties:@{
        @"key_1" : @"value_1",
        @"key_2" : @"value_2",
        @"int_key": @3,
        @"float_key": @4.56,
        @"bool_key": @YES,
        @"null_key": [[NSNull alloc] init],
        @"date_key": [[NSDate alloc] init],
        @"url_key": [[NSURL alloc] initWithString:@"https://rudderstack.com"]
    } options: [RSOption putContext:@"Ruchira" value:@"false"]];

   [[RSClient sharedInstance] identify:@"test_user_id"];
    [[RSClient sharedInstance] identify:@"test_user_id"
                                 traits:@{@"foo": @"bar",
                                          @"foo1": @"bar1",
                                          @"email": @"test@gmail.com",
                                          @"key_1" : @"value_1",
                                          @"key_2" : @"value_2"
                                 }
     options:[RSOption setIntegration:@"Moitra" enabled:true]
    ];
//    [[RSClient sharedInstance] identify:@"test_user_id"
//                                 traits:@{@"int_key": @3,
//                                         @"float_key": @4.56,
//                                         @"bool_key": @YES,
//                                         @"null_key": [[NSNull alloc] init],
//                                         @"date_key": [[NSDate alloc] init],
//                                         @"url_key": [[NSURL alloc] initWithString:@"https://rudderstack.com"]
//                                 }
//    ];

//    [[RSClient sharedInstance] track:@"identified_track_event"];
//
    [[RSClient sharedInstance] screen:@"Main" properties:@{@"prop_key" : @"prop_value",
                                                           @"key_1" : @"value_1",
                                                           @"key_2" : @"value_2",
                                                           @"int_key": @3,
                                                           @"float_key": @4.56,
                                                           @"bool_key": @YES,
                                                           @"null_key": [[NSNull alloc] init],
                                                           @"date_key": [[NSDate alloc] init],
                                                           @"url_key": [[NSURL alloc] initWithString:@"https://rudderstack.com"]
    }];

//    [[RSClient sharedInstance] reset];

//    [[RSClient sharedInstance] track:@"reset_track_event"];

    [[RSClient sharedInstance] alias:@"new_user_id"];
    
[[RSClient sharedInstance] alias:@"new_user_id" options:[RSOption setIntegration:@"abc" enabled:true]];
    [[RSClient sharedInstance] group:@"sample_group_id"
                              traits:@{@"foo": @"bar",
                                       @"foo1": @"bar1",
                                       @"email": @"test@gmail.com",
                                       @"key_1" : @"value_1",
                                       @"key_2" : @"value_2",
                                       @"int_key": @3,
                                       @"float_key": @4.56,
                                       @"bool_key": @YES,
                                       @"null_key": [[NSNull alloc] init],
                                       @"date_key": [[NSDate alloc] init],
                                       @"url_key": [[NSURL alloc] initWithString:@"https://rudderstack.com"]
                              }
    ];
    [[RSClient sharedInstance] group:@"sample_group_id"
                              traits:@{@"foo": @"bar",
                                       @"foo1": @"bar1",
                                       @"email": @"test@gmail.com",
                                       @"key_1" : @"value_1",
                                       @"key_2" : @"value_2",
                                       @"int_key": @3,
                                       @"float_key": @4.56,
                                       @"bool_key": @YES,
                                       @"null_key": [[NSNull alloc] init],
                                       @"date_key": [[NSDate alloc] init],
                                       @"url_key": [[NSURL alloc] initWithString:@"https://rudderstack.com"]
                              }
     options:[RSOption putContext:@"xyz" value:@"Hi"]
    ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
