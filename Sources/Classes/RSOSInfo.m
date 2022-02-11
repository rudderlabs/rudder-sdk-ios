//
//  RSOSInfo.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSOSInfo.h"
#if TARGET_OS_WATCH
#import <WatchKit/WKInterfaceDevice.h>
#endif


@implementation RSOSInfo

- (instancetype)init
{
    self = [super init];
   if (self) {
#if !TARGET_OS_WATCH
        UIDevice *device = [UIDevice currentDevice];
        _name = [device systemName];
        _version = [device systemVersion];
#else
       _name = [[WKInterfaceDevice currentDevice]systemName];
       _version = [[WKInterfaceDevice currentDevice]systemVersion];
#endif
    }
    return self;
}
- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict;
    @synchronized (tempDict) {
        tempDict = [[NSMutableDictionary alloc] init];
    
        [tempDict setValue:_name forKey:@"name"];
        [tempDict setValue:_version forKey:@"version"];
        
        return [tempDict copy];
    }
}
@end
