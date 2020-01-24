//
//  ProductListFilteredEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ProductListFilteredEvent.h"
#import "ECommerceParamNames.h"

@implementation ProductListFilteredEvent

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

- (instancetype)withFilters:(NSArray<ECommerceFilter *> *)filters {
    if (_filters == nil) {
        _filters = [filters mutableCopy];
    } else {
        [_filters addObjectsFromArray:filters];
    }
    return self;
}

- (instancetype)withFilter:(ECommerceFilter *)filter {
    if (_filters == nil) {
        _filters = [[NSMutableArray alloc] init];
    }
    [_filters addObject:filter];
    return self;
}

- (instancetype)withSorts:(NSArray<ECommerceSort *> *)sorts {
    if (_sorts == nil) {
        _sorts = [sorts mutableCopy];
    } else {
        [_sorts addObjectsFromArray:sorts];
    }
    return self;
}

- (instancetype)withSort:(ECommerceSort *)sort {
    if (_sorts == nil) {
        _sorts = [[NSMutableArray alloc] init];
    }
    [_sorts addObject:sort];
    return  self;
}

- (NSString *)event {
    return ECommProductListFiltered;
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
    
    if (_sorts != nil) {
        NSMutableArray *sortsArr = [[NSMutableArray alloc] init];
        for (ECommerceSort *sort in _sorts) {
            if (sort != nil) {
                [sortsArr addObject:[sort dict]];
            }
        }
        [tempDict setValue:sortsArr forKey:KeySorts];
    }
    
    if (_filters != nil) {
        NSMutableArray *filterArr = [[NSMutableArray alloc] init];
        for (ECommerceFilter *filter in _filters) {
            if (filter != nil) {
                [filterArr addObject:[filter dict]];
            }
        }
        [tempDict setValue:filterArr forKey:KeyFilters];
    }
    
    return [tempDict copy];
}

@end
