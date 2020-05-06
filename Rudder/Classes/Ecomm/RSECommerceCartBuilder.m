//
//  RSECommerceCartBuilder.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommerceCartBuilder.h"

@implementation RSECommerceCartBuilder

- (instancetype)withCartId:(NSString *)cartId {
    [self _initiateCart];
    _cart.cartId = cartId;
    return self;
}

- (instancetype)withProducts:(NSArray<RSECommerceProduct *> *)products {
    [self _initiateCart];
    _cart.products = [products mutableCopy];
    return self;
}

- (instancetype)withProduct:(RSECommerceProduct *)product {
    [self _initiateCart];
    [_cart setProduct:product];
    return self;
}

- (void) _initiateCart {
    if (_cart == nil) {
        _cart = [[RSECommerceCart alloc] init];
    }
}

- (RSECommerceCart *) build {
    [self _initiateCart];
    return _cart;
}

@end
