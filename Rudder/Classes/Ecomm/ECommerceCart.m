//
//  ECommerceCart.m
//  Adjust
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ECommerceCart.h"

@implementation ECommerceCart

- (void)setProduct: (ECommerceProduct *) product {
    if (_products == nil) {
        _products = [[NSMutableArray alloc] init];
    }
    [_products addObject:product];
}

- (NSDictionary *) dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    if (_cartId != nil) {
        [tempDict setValue:_cartId forKey:@"cart_id"];
    }
    if (_products != nil) {
        NSMutableArray *tempProductArr = [[NSMutableArray alloc] init];
        for (ECommerceProduct *product in _products) {
            [tempProductArr addObject:[product dict]];
        }
        [tempDict setValue:tempProductArr forKey:@"products"];
    }
    return [tempDict copy];
    
}

@end
