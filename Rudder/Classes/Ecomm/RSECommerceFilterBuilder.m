//
//  RSECommerceFilterBuilder.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommerceFilterBuilder.h"

@implementation RSECommerceFilterBuilder

- (instancetype)withType:(NSString *)type {
    [self _initiate];
    _filter.type = type;
    return self;
}

- (instancetype)withValue:(NSString *)value {
    [self _initiate];
    _filter.value = value;
    return self;
}

- (RSECommerceFilter *)build {
    [self _initiate];
    return _filter;
}

- (void) _initiate {
    if (_filter == nil) {
        _filter = [[RSECommerceFilter alloc] init];
    }
}

@end
