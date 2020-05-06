//
//  ECommerceCartBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceCart.h"
#import "ECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECommerceCartBuilder : NSObject

@property (nonatomic, strong) ECommerceCart* cart;

- (instancetype) withCartId: (NSString *) cartId;
- (instancetype) withProducts: (NSArray<ECommerceProduct*>*) products;
- (instancetype) withProduct: (ECommerceProduct*) product;
- (ECommerceCart*) build;

@end

NS_ASSUME_NONNULL_END
