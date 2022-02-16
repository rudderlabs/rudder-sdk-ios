//
//  RSScreenInfo.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSScreenInfo.h"
#if TARGET_OS_WATCH
#import <WatchKit/WKInterfaceDevice.h>
#endif


@implementation RSScreenInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
#if !TARGET_OS_WATCH
        CGRect bounds = [[UIScreen mainScreen] bounds];
        _density = [[UIScreen mainScreen] scale];
#else
        CGRect bounds = [[WKInterfaceDevice currentDevice] screenBounds];
        _density = [[WKInterfaceDevice currentDevice] screenScale];
#endif
        _height = bounds.size.width;
        _width = bounds.size.height;
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict;
    @synchronized (tempDict) {
        tempDict = [[NSMutableDictionary alloc] init];
    
        [tempDict setValue:[NSNumber numberWithInt:_density] forKey:@"density"];
        [tempDict setValue:[NSNumber numberWithInt:_height] forKey:@"height"];
        [tempDict setValue:[NSNumber numberWithInt:_width] forKey:@"width"];
        
        return [tempDict copy];
    }
}

@end
