//
//  WishListProductAddedToCartEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceWishList.h"
#import "RSECommerceProduct.h"
#import "RSECommerceCart.h"
#import "RSECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface WishListProductAddedToCartEvent : NSObject

@property (nonatomic, strong) RSECommerceWishList *wishList;
@property (nonatomic, strong) RSECommerceProduct *product;
@property (nonatomic, strong) NSString *cartId;
@property (nonatomic, strong) RSECommerceCart *cart;

- (instancetype) withWishList: (RSECommerceWishList*) wishList;
- (instancetype) withProduct: (RSECommerceProduct*) product;
- (instancetype) withCartId: (NSString*) cartId;
- (instancetype) withCart: (RSECommerceCart*) cart;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
