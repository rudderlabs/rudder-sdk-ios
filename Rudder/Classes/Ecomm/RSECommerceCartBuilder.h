//
//  RSECommerceCartBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceCart.h"
#import "RSECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceCartBuilder : NSObject

@property (nonatomic, strong) RSECommerceCart* cart;

- (instancetype) withCartId: (NSString *) cartId;
- (instancetype) withProducts: (NSArray<RSECommerceProduct*>*) products;
- (instancetype) withProduct: (RSECommerceProduct*) product;
- (RSECommerceCart*) build;

@end

NS_ASSUME_NONNULL_END
