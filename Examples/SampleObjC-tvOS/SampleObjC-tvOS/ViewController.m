//
//  ViewController.m
//  Sample-tvOS
//
//  Created by Desu Sai Venkat on 18/10/21.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController () {
    AppDelegate *appDelegate;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (IBAction)identify:(id)sender {
    [appDelegate identify];
}
- (IBAction)track:(id)sender {
    [appDelegate track];
}
- (IBAction)reset:(id)sender {
    [appDelegate reset];
}
- (IBAction)optIn:(id)sender {
    [appDelegate optIn];
}
- (IBAction)optOut:(id)sender {
    [appDelegate optOut];
}
- (IBAction)screen:(id)sender {
    [appDelegate screen];
}

@end
