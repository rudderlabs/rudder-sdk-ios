//
//  ProductAddedToWishListEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ProductAddedToWishListEvent.h"
#import "ECommerceParamNames.h"

@implementation ProductAddedToWishListEvent

- (instancetype)withWishList:(ECommerceWishList *)wishList {
    _wishList = wishList;
    return self;
}

- (instancetype)withProduct:(ECommerceProduct *)product {
    _product = product;
    return self;
}

- (NSString *)event {
    return ECommProductAddedToWishList;
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
    
    return [tempDict copy];
}

@end
