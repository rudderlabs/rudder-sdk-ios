//
//  ECommerceCheckoutBuilder.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ECommerceCheckoutBuilder.h"

@implementation ECommerceCheckoutBuilder

- (instancetype)withCheckoutId:(NSString *)checkoutId {
    [self _initiate];
    _checkout.checkoutId = checkoutId;
    return self;
}

- (instancetype)withOrderId:(NSString *)orderId {
    [self _initiate];
    _checkout.orderId = orderId;
    return self;
}

- (instancetype)withStep:(int)step {
    [self _initiate];
    _checkout.step = step;
    return self;
}

- (instancetype)withShippingMethod:(NSString *)shippingMethod {
    [self _initiate];
    _checkout.shippingMethod = shippingMethod;
    return self;
}

- (instancetype)withPaymentMethod:(NSString *)paymentMethod {
    [self _initiate];
    _checkout.paymentMethod = paymentMethod;
    return self;
}

- (ECommerceCheckout *)build {
    [self _initiate];
    return _checkout;
}

- (void) _initiate {
    if (_checkout == nil) {
        _checkout = [[ECommerceCheckout alloc] init];
    }
}

@end
