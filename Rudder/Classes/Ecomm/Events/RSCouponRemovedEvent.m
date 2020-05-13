//
//  CouponRemovedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSCouponRemovedEvent.h"
#import "RSECommerceParamNames.h"

@implementation CouponRemovedEvent

- (instancetype)withCoupon:(RSECommerceCoupon *)coupon {
    _coupon = coupon;
    return self;
}

- (NSString *)event {
    return ECommCouponRemoved;
}

- (NSDictionary *)properties {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_coupon != nil) {
        [tempDict setValue:_coupon.couponId forKey:KeyCouponId];
        [tempDict setValue:_coupon.couponName forKey:KeyCouponName];
        [tempDict setValue:[[NSNumber alloc] initWithFloat:_coupon.discount] forKey:KeyDiscount];
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
