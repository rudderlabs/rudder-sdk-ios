//
//  RSLibraryInfo.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSLibraryInfo.h"

@implementation RSLibraryInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        _name = @"rudder-ios-library";
        _version = @"1.0.3-beta.4";
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
