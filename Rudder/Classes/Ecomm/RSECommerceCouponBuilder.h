//
//  RSECommerceCouponBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceCoupon.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceCouponBuilder : NSObject

@property (nonatomic, strong) RSECommerceCoupon* coupon;

- (instancetype) withCartId: (NSString*) cartId;
- (instancetype) withOrderId: (NSString*) orderId;
- (instancetype) withCouponId: (NSString*) couponId;
- (instancetype) withCouponName: (NSString*) couponName;
- (instancetype) withDiscount: (float) discount;
- (instancetype) withReason: (NSString*) reason;
- (RSECommerceCoupon*) build;

@end

NS_ASSUME_NONNULL_END
