//
//  CouponEnteredEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceCoupon.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface CouponEnteredEvent : NSObject

@property (nonatomic, strong) ECommerceCoupon *coupon;

- (instancetype) withCoupon: (ECommerceCoupon*) coupon;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
