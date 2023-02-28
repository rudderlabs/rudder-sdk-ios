//
//  RSECommerceWishListBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceWishList.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceWishListBuilder : NSObject

@property (nonatomic, strong) RSECommerceWishList *wishList;

- (instancetype) withWishListId: (NSString*) wishListId;
- (instancetype) withWishListName: (NSString*) wishListName;
- (RSECommerceWishList*) build;


@end

NS_ASSUME_NONNULL_END
