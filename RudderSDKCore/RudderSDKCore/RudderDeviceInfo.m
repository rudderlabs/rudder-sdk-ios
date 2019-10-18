//
//  RudderDeviceInfo.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderDeviceInfo.h"
#import <UIKit/UIKit.h>

@implementation RudderDeviceInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _identifier = [[[[UIDevice currentDevice] identifierForVendor] UUIDString]lowercaseString];
        _manufacturer = @"Apple";
        _model = [[UIDevice currentDevice] model];
        _name = [[UIDevice currentDevice] name];
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    [tempDict setValue:_identifier forKey:@"id"];
    [tempDict setValue:_manufacturer forKey:@"manufacturer"];
    [tempDict setValue:_model forKey:@"model"];
    [tempDict setValue:_name forKey:@"name"];
    
    return [tempDict copy];
}

@end
