//
//  ProductAddedToCartEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceEvents.h"
#import "RSECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductAddedToCartEvent : NSObject

@property (nonatomic, strong) RSECommerceProduct *product;
@property (nonatomic, strong) NSString *cartId;

- (instancetype) withProduct: (RSECommerceProduct*) product;
- (instancetype) withCartId: (NSString*) cartId;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
