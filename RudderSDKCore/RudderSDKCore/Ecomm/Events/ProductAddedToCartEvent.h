//
//  ProductAddedToCartEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceEvents.h"
#import "ECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductAddedToCartEvent : NSObject

@property (nonatomic, strong) ECommerceProduct *product;
@property (nonatomic, strong) NSString *cartId;

- (instancetype) withProduct: (ECommerceProduct*) product;
- (instancetype) withCartId: (NSString*) cartId;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
