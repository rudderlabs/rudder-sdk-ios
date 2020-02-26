//
//  ECommerceFilterBuilder.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ECommerceFilterBuilder.h"

@implementation ECommerceFilterBuilder

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

- (ECommerceFilter *)build {
    [self _initiate];
    return _filter;
}

- (void) _initiate {
    if (_filter == nil) {
        _filter = [[ECommerceFilter alloc] init];
    }
}

@end
