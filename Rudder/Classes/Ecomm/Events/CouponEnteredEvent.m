//
//  CouponEnteredEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "CouponEnteredEvent.h"
#import "ECommerceParamNames.h"

@implementation CouponEnteredEvent

- (instancetype)withCoupon:(ECommerceCoupon *)coupon {
    _coupon = coupon;
    return self;
}

- (NSString *)event {
    return ECommCouponEntered;
}

- (NSDictionary *)properties {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_coupon != nil) {
        [tempDict setValue:_coupon.couponId forKey:KeyCouponId];
        if (_coupon.orderId != nil) {
            [tempDict setValue:_coupon.orderId forKey:KeyOrderId];
        }
        if (_coupon.cartId != nil) {
            [tempDict setValue:_coupon.cartId forKey:KeyCartId];
        }
    }
    
    return [tempDict copy];
}

@end
