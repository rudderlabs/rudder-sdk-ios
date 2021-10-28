//
//  CartViewedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSCartViewedEvent.h"
#import "RSECommerceParamNames.h"

@implementation CartViewedEvent

- (instancetype)withCart:(RSECommerceCart *)cart {
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
