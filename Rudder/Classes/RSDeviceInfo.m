//
//  RSDeviceInfo.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSDeviceInfo.h"
#import <UIKit/UIKit.h>

@implementation RSDeviceInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        _identifier = [[[[UIDevice currentDevice] identifierForVendor] UUIDString]lowercaseString];
        _manufacturer = @"Apple";
        _model = [[UIDevice currentDevice] model];
        _name = [[UIDevice currentDevice] name];
        _type = @"ios";
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    [tempDict setValue:_identifier forKey:@"id"];
    [tempDict setValue:_manufacturer forKey:@"manufacturer"];
    [tempDict setValue:_model forKey:@"model"];
    [tempDict setValue:_name forKey:@"name"];
    [tempDict setValue:_type forKey:@"type"];
    if (_token != nil) {
        [tempDict setValue:_token forKey:@"token"];
    }
    
    return [tempDict copy];
}

@end
