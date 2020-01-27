//
//  ECommerceOrderBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceOrder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECommerceOrderBuilder : NSObject

@property (nonatomic, strong) ECommerceOrder *order;

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
- (instancetype) withProducts: (NSMutableArray<ECommerceProduct*>*) products;
- (instancetype) withProduct: (ECommerceProduct*) product;
- (ECommerceOrder*) build;


@end

NS_ASSUME_NONNULL_END
