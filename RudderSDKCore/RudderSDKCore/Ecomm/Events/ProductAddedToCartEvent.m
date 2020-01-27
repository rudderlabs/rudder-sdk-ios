//
//  ProductAddedToCartEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ProductAddedToCartEvent.h"
#import "ECommerceParamNames.h"

@implementation ProductAddedToCartEvent

- (instancetype)withProduct:(ECommerceProduct *)product {
    _product = product;
    return self;
}

- (instancetype)withCartId:(NSString *)cartId {
    _cartId = cartId;
    return self;
}

- (NSString *)event {
    return ECommProductAdded;
}

- (NSDictionary *)properties {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_product != nil) {
        [tempDict setDictionary:_product.dict];
    }
    
    if (_cartId != nil) {
        [tempDict setValue:_cartId forKey:KeyCartId];
    }
    
    return [tempDict copy];
}

@end
