//
//  ProductListViewedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ProductListViewedEvent.h"
#import "ECommerceParamNames.h"

@implementation ProductListViewedEvent

- (instancetype)withListId:(NSString *)listId{
    _listId = listId;
    return self;
}

- (instancetype) withProduct:(ECommerceProduct *)product {
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

- (instancetype)withCategory:(NSString *)category {
    _category = category;
    return self;
}

- (NSString *)event {
    return ECommProductListViewed;
}

- (NSDictionary *)properties {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];

    if (_listId != nil) {
        [tempDict setValue:_listId forKey:KeyListId];
    }
    
    if (_category != nil) {
        [tempDict setValue:_category forKey:KeyCategory];
    }
    
    if (_products != nil) {
        NSMutableArray *productArr = [[NSMutableArray alloc] init];
        for (ECommerceProduct *product in _products) {
            if (product != nil) {
                [productArr addObject:[product dict]];
            }
        }
        [tempDict setValue:productArr forKey:KeyProducts];
    }
    
    return [tempDict copy];
}

@end
