//
//  ProductRemovedFromWishListEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceWishList.h"
#import "ECommerceProduct.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductRemovedFromWishListEvent : NSObject

@property (nonatomic, strong) ECommerceWishList *wishList;
@property (nonatomic, strong) ECommerceProduct *product;

- (instancetype) withWishList: (ECommerceWishList*) wishList;
- (instancetype) withProduct: (ECommerceProduct*) product;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
