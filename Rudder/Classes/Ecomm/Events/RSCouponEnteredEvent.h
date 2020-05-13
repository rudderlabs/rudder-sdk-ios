//
//  CouponEnteredEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceCoupon.h"
#import "RSECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface CouponEnteredEvent : NSObject

@property (nonatomic, strong) RSECommerceCoupon *coupon;

- (instancetype) withCoupon: (RSECommerceCoupon*) coupon;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
