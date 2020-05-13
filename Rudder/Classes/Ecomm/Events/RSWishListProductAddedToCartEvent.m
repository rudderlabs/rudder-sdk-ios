//
//  WishListProductAddedToCartEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSWishListProductAddedToCartEvent.h"
#import "RSECommerceParamNames.h"

@implementation WishListProductAddedToCartEvent

- (instancetype)withWishList:(RSECommerceWishList *)wishList {
    _wishList = wishList;
    return self;
}

- (instancetype)withProduct:(RSECommerceProduct *)product {
    _product = product;
    return self;
}

- (instancetype)withCartId:(NSString *)cartId {
    _cartId = cartId;
    return self;
}

- (instancetype)withCart:(RSECommerceCart *)cart {
    _cart = cart;
    return self;
}

- (NSString *)event {
    return ECommWishListProductAddedToCart;
}

- (NSDictionary *)properties {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_product != nil) {
        [tempDict setDictionary:[_product dict]];
    }
    
    if (_wishList != nil) {
        [tempDict setValue:_wishList.wishListId forKey:KeyWishlistId];
        [tempDict setValue:_wishList.wishListName forKey:KeyWishlistName];
    }
    
    if (_cartId != nil) {
        [tempDict setValue:_cartId forKey:KeyCartId];
    } else if (_cart != nil) {
        [tempDict setValue:_cart.cartId forKey:KeyCartId];
    }
    
    return [tempDict copy];
}

@end
