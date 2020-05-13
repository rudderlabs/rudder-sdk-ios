//
//  CheckoutStepViewedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSCheckoutStepViewedEvent.h"

@implementation CheckoutStepViewedEvent

- (instancetype)withCheckout:(RSECommerceCheckout *)checkout {
    _checkout = checkout;
    return self;
}

- (NSString *)event {
    return ECommCheckoutStepViewed;
}

- (NSDictionary *)properties {
    if (_checkout == nil) {
        return @{};
    } else {
        return [_checkout dict];
    }
}

@end
