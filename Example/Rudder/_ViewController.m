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
    
//    [[RudderClient sharedInstance] track:@"simple_track_event"];
//    [[RudderClient sharedInstance] track:@"simple_track_with_props" properties:@{
//        @"key_1" : @"value_1",
//        @"key_2" : @"value_2"
//    }];
    
    [[RudderClient sharedInstance] identify:@"test_user_id"];
    
    [[RudderClient sharedInstance] track:@"identified_track_event"];
    
//    [[RudderClient sharedInstance] screen:@"Main" properties:@{@"prop_key" : @"prop_value"}];
    
//    [[RudderClient sharedInstance] reset];
    
//    [[RudderClient sharedInstance] track:@"reset_track_event"];
    
    [[RudderClient sharedInstance] alias:@"new_user_id"];
    
[[RudderClient sharedInstance] group:@"sample_group_id"
                              traits:@{@"foo": @"bar",
                                       @"foo1": @"bar1",
                                       @"email": @"ruchira@gmail.com"}
 ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
