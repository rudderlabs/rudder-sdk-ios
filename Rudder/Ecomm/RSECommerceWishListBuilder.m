//
//  RSECommerceWishListBuilder.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommerceWishListBuilder.h"

@implementation RSECommerceWishListBuilder

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

- (RSECommerceWishList *)build {
    [self _initiate];
    return _wishList;
}

- (void) _initiate {
    if (_wishList == nil) {
        _wishList = [[RSECommerceWishList alloc] init];
    }
}

@end
