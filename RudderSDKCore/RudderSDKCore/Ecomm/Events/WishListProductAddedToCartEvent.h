//
//  WishListProductAddedToCartEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceWishList.h"
#import "ECommerceProduct.h"
#import "ECommerceCart.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface WishListProductAddedToCartEvent : NSObject

@property (nonatomic, strong) ECommerceWishList *wishList;
@property (nonatomic, strong) ECommerceProduct *product;
@property (nonatomic, strong) NSString *cartId;
@property (nonatomic, strong) ECommerceCart *cart;

- (instancetype) withWishList: (ECommerceWishList*) wishList;
- (instancetype) withProduct: (ECommerceProduct*) product;
- (instancetype) withCartId: (NSString*) cartId;
- (instancetype) withCart: (ECommerceCart*) cart;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
