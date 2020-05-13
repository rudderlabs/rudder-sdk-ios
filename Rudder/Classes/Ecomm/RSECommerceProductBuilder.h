//
//  RSECommerceProductBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceProductBuilder : NSObject

@property (nonatomic, strong) RSECommerceProduct *product;

- (instancetype) withProductId: (NSString*) productId;
- (instancetype) withSku: (NSString*) sku;
- (instancetype) withCategory: (NSString*) category;
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
- (RSECommerceProduct*) build;

@end

NS_ASSUME_NONNULL_END
