//
//  ECommerceProductBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECommerceProductBuilder : NSObject

@property (nonatomic, strong) ECommerceProduct *product;

- (instancetype) withProductId: (NSString*) productId;
- (instancetype) withSku: (NSString*) sku;
- (instancetype) withName: (NSString*) name;
- (instancetype) withBrand: (NSString*) brand;
- (instancetype) withVariant: (NSString*) variant;
- (instancetype) withPrice: (float) price;
- (instancetype) withCurrency: (NSString*) currency;
- (instancetype) withQuantity: (float) quantity;
- (instancetype) withCoupon: (NSString*) coupon;
- (instancetype) withPosition: (int) position;
- (instancetype) withUrl: (NSString*) url;
- (instancetype) withImageUrl: (NSString*) imageUrl;
- (ECommerceProduct*) build;

@end

NS_ASSUME_NONNULL_END
