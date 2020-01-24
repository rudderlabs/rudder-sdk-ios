//
//  CartViewedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "CartViewedEvent.h"
#import "ECommerceParamNames.h"

@implementation CartViewedEvent

- (instancetype)withCart:(ECommerceCart *)cart {
    _cart = cart;
    return self;
}

- (NSString *)event {
    return ECommCartViewed;
}

- (NSDictionary *)properties {
    if (_cart == nil) {
        return @{};
    } else {
        return [_cart dict];
    }
}

@end
