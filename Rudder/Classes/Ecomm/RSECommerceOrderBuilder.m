//
//  RSECommerceOrderBuilder.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommerceOrderBuilder.h"

@implementation RSECommerceOrderBuilder

- (instancetype)withOrderId:(NSString *)orderId {
    [self _initiate];
    _order.orderId = orderId;
    return self;
}

- (instancetype)withAffiliation:(NSString *)affiliation {
    [self _initiate];
    _order.affiliation = affiliation;
    return self;
}

- (instancetype)withTotal:(float)total {
    [self _initiate];
    _order.total = total;
    return self;
}

- (instancetype)withValue:(float)value {
    [self _initiate];
    _order.value = value;
    return self;
}

- (instancetype)withRevenue:(float)revenue {
    [self _initiate];
    _order.revenue = revenue;
    return self;
}

- (instancetype)withShippingCost:(float)shippingCost {
    [self _initiate];
    _order.shippingCost = shippingCost;
    return self;
}

- (instancetype)withTax:(float)tax {
    [self _initiate];
    _order.tax = tax;
    return self;
}

- (instancetype)withDiscount:(float)discount {
    [self _initiate];
    _order.discount = discount;
    return self;
}

- (instancetype)withCoupon:(NSString *)coupon {
    [self _initiate];
    _order.coupon = coupon;
    return self;
}

- (instancetype)withCurrency:(NSString *)currency {
    [self _initiate];
    _order.currency = currency;
    return self;
}

- (instancetype)withProducts:(NSMutableArray<RSECommerceProduct *> *)products {
    [self _initiate];
    _order.products = products;
    return self;
}

- (instancetype)withProduct:(RSECommerceProduct *)product {
    [self _initiate];
    [_order setProduct:product];
    return self;
}

- (RSECommerceOrder *)build {
    [self _initiate];
    return _order;
}

- (void) _initiate {
    if (_order == nil) {
        _order = [[RSECommerceOrder alloc] init];
    }
}

@end
