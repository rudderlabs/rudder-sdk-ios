//
//  ProductAddedToWishListEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceWishList.h"
#import "RSECommerceProduct.h"
#import "RSECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductAddedToWishListEvent : NSObject

@property (nonatomic, strong) RSECommerceWishList *wishList;
@property (nonatomic, strong) RSECommerceProduct *product;

- (instancetype) withWishList: (RSECommerceWishList*) wishList;
- (instancetype) withProduct: (RSECommerceProduct*) product;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
