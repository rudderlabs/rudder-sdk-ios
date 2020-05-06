//
//  CouponDeniedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSCouponDeniedEvent.h"
#import "RSECommerceParamNames.h"

@implementation CouponDeniedEvent

- (instancetype)withCoupon:(RSECommerceCoupon *)coupon {
    _coupon = coupon;
    return self;
}

- (NSString *)event {
    return ECommCouponDenied;
}

- (NSDictionary *)properties {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_coupon != nil) {
        [tempDict setValue:_coupon.couponId forKey:KeyCouponId];
        [tempDict setValue:_coupon.couponName forKey:KeyCouponName];
        if (_coupon.orderId != nil) {
            [tempDict setValue:_coupon.orderId forKey:KeyOrderId];
        }
        if (_coupon.cartId != nil) {
            [tempDict setValue:_coupon.cartId forKey:KeyCartId];
        }
        if (_coupon.reason != nil) {
            [tempDict setValue:_coupon.reason forKey:KeyReason];
        }
    }
    
    return [tempDict copy];
}

@end
