//
//  RudderLibraryInfo.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderLibraryInfo.h"

@implementation RudderLibraryInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = @"rudder-ios-library";
        _version = @"1.0";
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    [tempDict setValue:_name forKey:@"name"];
    [tempDict setValue:_version forKey:@"version"];
    
    return [tempDict copy];
}

@end
