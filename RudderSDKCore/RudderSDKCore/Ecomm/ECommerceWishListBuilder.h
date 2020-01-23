//
//  ECommerceWishListBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceWishList.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECommerceWishListBuilder : NSObject

@property (nonatomic, strong) ECommerceWishList *wishList;

- (instancetype) withWishListId: (NSString*) wishListId;
- (instancetype) withWishListName: (NSString*) wishListName;
- (ECommerceWishList*) build;


@end

NS_ASSUME_NONNULL_END
