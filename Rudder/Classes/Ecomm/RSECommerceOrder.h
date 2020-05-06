//
//  ECommerceOrder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECommerceOrder : NSObject

@property (nonatomic, strong) NSString* orderId;
@property (nonatomic, strong) NSString* affiliation;
@property (nonatomic) float total;
@property (nonatomic) float value;
@property (nonatomic) float revenue;
@property (nonatomic) float shippingCost;
@property (nonatomic) float tax;
@property (nonatomic) float discount;
@property (nonatomic, strong) NSString* coupon;
@property (nonatomic, strong) NSString* currency;
@property (nonatomic, strong) NSMutableArray<ECommerceProduct*>* products;

- (void) setProduct: (ECommerceProduct* _Nonnull) product;
- (NSDictionary*) dict;

@end

NS_ASSUME_NONNULL_END
