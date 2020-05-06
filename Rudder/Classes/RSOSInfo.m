//
//  RSOSInfo.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSOSInfo.h"

@implementation RSOSInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIDevice *device = [UIDevice currentDevice];
        _name = [device systemName];
        _version = [device systemVersion];
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
