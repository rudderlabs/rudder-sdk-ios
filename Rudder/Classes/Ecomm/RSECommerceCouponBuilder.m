//
//  RSECommerceCouponBuilder.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommerceCouponBuilder.h"

@implementation RSECommerceCouponBuilder

- (instancetype)withCartId:(NSString *)cartId {
    [self _initiate];
    _coupon.cartId = cartId;
    return self;
}

- (instancetype)withOrderId:(NSString *)orderId {
    [self _initiate];
    _coupon.orderId = orderId;
    return self;
}

- (instancetype)withCouponId:(NSString *)couponId {
    [self _initiate];
    _coupon.couponId = couponId;
    return self;
}

- (instancetype)withCouponName:(NSString *)couponName {
    [self _initiate];
    _coupon.couponName = couponName;
    return self;
}

- (instancetype)withDiscount:(float)discount {
    [self _initiate];
    _coupon.discount = discount;
    return self;
}

- (instancetype)withReason:(NSString *)reason {
    [self _initiate];
    _coupon.reason = reason;
    return self;
}

- (RSECommerceCoupon *)build {
    [self _initiate];
    return _coupon;
}

- (void) _initiate {
    if (_coupon == nil) {
        _coupon = [[RSECommerceCoupon alloc] init];
    }
}

@end
