//
//  OrderRefundedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "OrderRefundedEvent.h"
#import "ECommerceParamNames.h"

@implementation OrderRefundedEvent

- (instancetype)withOrder:(ECommerceOrder *)order {
    _order = order;
    return self;
}

- (instancetype)withProduct:(ECommerceProduct *)product {
    if (_products == nil) {
        _products = [[NSMutableArray alloc] init];
    }
    [_products addObject:product];
    return self;
}

- (instancetype)withProducts:(NSArray<ECommerceProduct *> *)products {
    if (_products == nil) {
        _products = [products mutableCopy];
    } else {
        [_products addObjectsFromArray:products];
    }
    return self;
}

- (instancetype)withRefundValue:(float)value {
    _value = value;
    return self;
}

- (NSString *)event {
    return ECommOrderRefunded;
}

- (NSDictionary *)properties {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_order != nil) {
        [tempDict setValue:_order.orderId forKey:KeyOrderId];
        [tempDict setValue:_order.currency forKey:KeyCurrency];
        [tempDict setValue:[[NSNumber alloc] initWithFloat:_value] forKey:KeyTotal];
    }
    
    if (_products != nil) {
        NSMutableArray *productArr = [[NSMutableArray alloc] init];
        for (ECommerceProduct *product in _products) {
            if (product != nil) {
                [productArr addObject:product.dict];
            }
        }
        [tempDict setValue:productArr forKey:KeyProducts];
    }
    
    return [tempDict copy];
}

@end
