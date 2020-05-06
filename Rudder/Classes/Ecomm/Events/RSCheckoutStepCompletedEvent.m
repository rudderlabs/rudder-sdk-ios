//
//  CheckoutStepCompletedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSCheckoutStepCompletedEvent.h"

@implementation CheckoutStepCompletedEvent

- (instancetype)withCheckout:(RSECommerceCheckout *)checkout {
    _checkout = checkout;
    return self;
}

- (NSString *)event {
    return ECommCheckoutStepCompleted;
}

- (NSDictionary *)properties {
    if (_checkout == nil) {
        return @{};
    } else {
        return [_checkout dict];
    }
}


@end
