//
//  ECommerceWishListBuilder.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ECommerceWishListBuilder.h"

@implementation ECommerceWishListBuilder

- (instancetype)withWishListId:(NSString *)wishListId {
    [self _initiate];
    _wishList.wishListId = wishListId;
    return self;
}

- (instancetype)withWishListName:(NSString *)wishListName {
    [self _initiate];
    _wishList.wishListName = wishListName;
    return self;
}

- (ECommerceWishList *)build {
    [self _initiate];
    return _wishList;
}

- (void) _initiate {
    if (_wishList == nil) {
        _wishList = [[ECommerceWishList alloc] init];
    }
}

@end
