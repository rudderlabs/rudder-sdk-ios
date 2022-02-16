//
//  RSApp.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSApp.h"

@implementation RSApp
- (instancetype)init
{
    self = [super init];
    if (self) {
        // Ref:  http://hboon.com/difference-between-cfbundleversion-and-cfbundleshortversionstring
        NSBundle *bundle = [NSBundle mainBundle];
        _build = [[bundle infoDictionary]valueForKey:@"CFBundleVersion"];
        _name = [[bundle infoDictionary]valueForKey:@"CFBundleName"];
        _nameSpace = [bundle bundleIdentifier];
        _version = [[bundle infoDictionary]valueForKey:@"CFBundleShortVersionString"];
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict;
    @synchronized (tempDict) {
        tempDict = [[NSMutableDictionary alloc] init];

        [tempDict setValue:_build forKey:@"build"];
        [tempDict setValue:_name forKey:@"name"];
        [tempDict setValue:_nameSpace forKey:@"namespace"];
        [tempDict setValue:_version forKey:@"version"];

        return [tempDict copy];
    }
}
@end
