//
//  ViewController.m
//  Sample-tvOS
//
//  Created by Desu Sai Venkat on 18/10/21.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)identify:(id)sender {
    [AppDelegate identify];
}
- (IBAction)track:(id)sender {
    [AppDelegate track];
}
- (IBAction)reset:(id)sender {
    [AppDelegate reset];
}
- (IBAction)optIn:(id)sender {
    [AppDelegate optIn];
}
- (IBAction)optOut:(id)sender {
    [AppDelegate optOut];
}
- (IBAction)screen:(id)sender {
    [AppDelegate screen];
}

@end
