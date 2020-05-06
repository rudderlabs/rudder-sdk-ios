//
//  RSECommerceCoupon.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommerceCoupon.h"

@implementation RSECommerceCoupon

- (NSDictionary*) dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_cartId != nil) {
        [tempDict setValue:_cartId forKey:@"cart_id"];
    }
    if (_orderId != nil) {
        [tempDict setValue:_orderId forKey:@"order_id"];
    }
    if (_couponId != nil) {
        [tempDict setValue:_couponId forKey:@"coupon_id"];
    }
    if (_couponName != nil) {
        [tempDict setValue:_couponName forKey:@"coupon_name"];
    }
    [tempDict setValue:[[NSNumber alloc] initWithFloat:_discount] forKey:@"discount"];
    if (_reason != nil) {
        [tempDict setValue:_reason forKey:@"reason"];
    }
    
    return [tempDict copy];
}

@end
