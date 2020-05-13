//
//  RSECommerceSortBuilder.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommerceSortBuilder.h"

@implementation RSECommerceSortBuilder

- (instancetype)withType:(NSString *)type {
    [self _initiate];
    _sort.type = type;
    return self;
}

- (instancetype)withValue:(NSString *)value {
    [self _initiate];
    _sort.value = value;
    return self;
}

- (RSECommerceSort *)build {
    [self _initiate];
    return _sort;
}

- (void) _initiate {
    if (_sort == nil) {
        _sort = [[RSECommerceSort alloc] init];
    }
}

@end
