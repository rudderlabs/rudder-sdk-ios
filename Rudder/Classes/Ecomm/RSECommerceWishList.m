//
//  ECommerceWishList.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ECommerceWishList.h"

@implementation ECommerceWishList

- (NSDictionary*) dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    if (_wishListId != nil) {
        [tempDict setValue:_wishListId forKey:@"wishlist_id"];
    }
    if (_wishListName != nil) {
        [tempDict setValue:_wishListName forKey:@"wishlist_name"];
    }
    return [tempDict copy];
}


@end
