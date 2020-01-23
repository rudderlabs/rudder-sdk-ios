//
//  ECommerceProductBuilder.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ECommerceProductBuilder.h"

@implementation ECommerceProductBuilder

- (instancetype)withProductId:(NSString *)productId {
    [self _initiate];
    _product.productId = productId;
    return self;
}

- (instancetype)withSku:(NSString *)sku {
    [self _initiate];
    _product.sku = sku;
    return self;
}

- (instancetype)withName:(NSString *)name {
    [self _initiate];
    _product.name = name;
    return self;
}

- (instancetype)withBrand:(NSString *)brand {
    [self _initiate];
    _product.brand = brand;
    return self;
}

- (instancetype)withVariant:(NSString *)variant {
    [self _initiate];
    _product.variant = variant;
    return self;
}

- (instancetype)withPrice:(float)price {
    [self _initiate];
    _product.price = price;
    return self;
}

- (instancetype)withCurrency:(NSString *)currency {
    [self _initiate];
    _product.currency = currency;
    return self;
}

- (instancetype)withQuantity:(float)quantity {
    [self _initiate];
    _product.quantity = quantity;
    return self;
}

- (instancetype)withCoupon:(NSString *)coupon {
    [self _initiate];
    _product.coupon = coupon;
    return self;
}

- (instancetype)withPosition:(int)position {
    [self _initiate];
    _product.position = position;
    return self;
}

- (instancetype)withUrl:(NSString *)url {
    [self _initiate];
    _product.url = url;
    return self;
}

- (instancetype)withImageUrl:(NSString *)imageUrl {
    [self _initiate];
    _product.imageUrl = imageUrl;
    return self;
}

- (ECommerceProduct *)build {
    [self _initiate];
    return _product;
}

- (void) _initiate {
    if (_product == nil) {
        _product = [[ECommerceProduct alloc] init];
    }
}

@end
