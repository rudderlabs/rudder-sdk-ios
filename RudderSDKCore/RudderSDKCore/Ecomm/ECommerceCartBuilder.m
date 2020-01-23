//
//  ECommerceCartBuilder.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ECommerceCartBuilder.h"

@implementation ECommerceCartBuilder

- (instancetype)withCartId:(NSString *)cartId {
    [self _initiateCart];
    _cart.cartId = cartId;
    return self;
}

- (instancetype)withProducts:(NSArray<ECommerceProduct *> *)products {
    [self _initiateCart];
    _cart.products = [products mutableCopy];
    return self;
}

- (instancetype)withProduct:(ECommerceProduct *)product {
    [self _initiateCart];
    [_cart setProduct:product];
    return self;
}

- (void) _initiateCart {
    if (_cart == nil) {
        _cart = [[ECommerceCart alloc] init];
    }
}

- (ECommerceCart *) build {
    [self _initiateCart];
    return _cart;
}

@end
