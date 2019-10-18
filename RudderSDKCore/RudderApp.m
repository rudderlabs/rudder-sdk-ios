//
//  RudderApp.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderApp.h"

@implementation RudderApp
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSBundle *bundle = [NSBundle mainBundle];
        _build = [[bundle infoDictionary]valueForKey:@"CFBundleShortVersionString"];
        _name = [[bundle infoDictionary]valueForKey:@"CFBundleName"];
        _nameSpace = [bundle bundleIdentifier];
        _version = [[bundle infoDictionary]valueForKey:@"CFBundleVersion"];
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    [tempDict setValue:_build forKey:@"build"];
    [tempDict setValue:_name forKey:@"name"];
    [tempDict setValue:_nameSpace forKey:@"namespace"];
    [tempDict setValue:_version forKey:@"version"];
    
    return [tempDict copy];
}
@end
