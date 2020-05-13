//
//  RSECommerceOrderBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceOrder.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceOrderBuilder : NSObject

@property (nonatomic, strong) RSECommerceOrder *order;

- (instancetype) withOrderId: (NSString*) orderId;
- (instancetype) withAffiliation: (NSString*) affiliation;
- (instancetype) withTotal: (float) total;
- (instancetype) withValue: (float) value;
- (instancetype) withRevenue: (float) revenue;
- (instancetype) withShippingCost: (float) shippingCost;
- (instancetype) withTax: (float) tax;
- (instancetype) withDiscount: (float) discount;
- (instancetype) withCoupon: (NSString*) coupon;
- (instancetype) withCurrency: (NSString*) currency;
- (instancetype) withProducts: (NSMutableArray<RSECommerceProduct*>*) products;
- (instancetype) withProduct: (RSECommerceProduct*) product;
- (RSECommerceOrder*) build;


@end

NS_ASSUME_NONNULL_END
