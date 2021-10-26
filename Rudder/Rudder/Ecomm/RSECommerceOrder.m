//
//  RSECommerceOrder.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommerceOrder.h"

@implementation RSECommerceOrder

- (void)setProduct:(RSECommerceProduct *)product {
    if(_products == nil) {
        _products = [[NSMutableArray alloc] init];
    }
    [_products addObject:product];
}

- (NSDictionary*) dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_orderId != nil) {
        [tempDict setValue:_orderId forKey:@"order_id"];
    }
    if (_affiliation != nil) {
        [tempDict setValue:_affiliation forKey:@"affiliation"];
    }
    [tempDict setValue:[[NSNumber alloc] initWithFloat:_total] forKey:@"total"];
    [tempDict setValue:[[NSNumber alloc] initWithFloat:_value] forKey:@"value"];
    [tempDict setValue:[[NSNumber alloc] initWithFloat:_revenue] forKey:@"revenue"];
    [tempDict setValue:[[NSNumber alloc] initWithFloat:_shippingCost] forKey:@"shipping"];
    [tempDict setValue:[[NSNumber alloc] initWithFloat:_tax] forKey:@"tax"];
    [tempDict setValue:[[NSNumber alloc] initWithFloat:_discount] forKey:@"discount"];
    
    if (_coupon != nil) {
        [tempDict setValue:_coupon forKey:@"coupon"];
    }
    if (_currency != nil) {
        [tempDict setValue:_currency forKey:@"currency"];
    }
    if (_products != nil) {
        NSMutableArray *tempProducts = [[NSMutableArray alloc] init];
        for (RSECommerceProduct *product in _products) {
            if (product != nil) {
                [tempProducts addObject:[product dict]];
            }
        }
        [tempDict setValue:tempProducts forKey:@"products"];
    }
    
    return [tempDict copy];
}

@end
