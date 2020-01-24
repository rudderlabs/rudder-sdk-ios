//
//  WishListProductAddedToCartEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "WishListProductAddedToCartEvent.h"
#import "ECommerceParamNames.h"

@implementation WishListProductAddedToCartEvent

- (instancetype)withWishList:(ECommerceWishList *)wishList {
    _wishList = wishList;
    return self;
}

- (instancetype)withProduct:(ECommerceProduct *)product {
    _product = product;
    return self;
}

- (instancetype)withCartId:(NSString *)cartId {
    _cartId = cartId;
    return self;
}

- (instancetype)withCart:(ECommerceCart *)cart {
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
