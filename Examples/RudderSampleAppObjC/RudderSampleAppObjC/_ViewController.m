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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendIdentify:(id)sender {
    [_AppDelegate sendIdentify];
}
- (IBAction)sendTrack:(id)sender {
    [_AppDelegate sendTrack];
}
- (IBAction)sendScreen:(id)sender {
    [_AppDelegate sendScreen];
}
- (IBAction)sendGroup:(id)sender {
    [_AppDelegate sendGroup];
}
- (IBAction)sendAlias:(id)sender {
    [_AppDelegate sendAlias];
}
- (IBAction)sendReset:(id)sender {
    [_AppDelegate sendReset];
}

@end
