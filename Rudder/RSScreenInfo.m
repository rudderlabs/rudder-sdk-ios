//
//  RSScreenInfo.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSScreenInfo.h"

@implementation RSScreenInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
        CGRect bounds = [[UIScreen mainScreen] bounds];
        _density = [[UIScreen mainScreen] scale];
        _height = bounds.size.width;
        _width = bounds.size.height;
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    [tempDict setValue:[NSNumber numberWithInt:_density] forKey:@"density"];
    [tempDict setValue:[NSNumber numberWithInt:_height] forKey:@"height"];
    [tempDict setValue:[NSNumber numberWithInt:_width] forKey:@"width"];
    
    return [tempDict copy];
}

@end
