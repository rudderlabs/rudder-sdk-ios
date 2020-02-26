//
//  ECommerceCouponBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceCoupon.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECommerceCouponBuilder : NSObject

@property (nonatomic, strong) ECommerceCoupon* coupon;

- (instancetype) withCartId: (NSString*) cartId;
- (instancetype) withOrderId: (NSString*) orderId;
- (instancetype) withCouponId: (NSString*) couponId;
- (instancetype) withCouponName: (NSString*) couponName;
- (instancetype) withDiscount: (float) discount;
- (instancetype) withReason: (NSString*) reason;
- (ECommerceCoupon*) build;

@end

NS_ASSUME_NONNULL_END
