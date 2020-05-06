//
//  ProductSearchedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ProductSearchedEvent.h"
#import "ECommerceParamNames.h"

@implementation ProductSearchedEvent

- (instancetype)withQuery:(NSString *)query {
    _query = query;
    return self;
}

- (NSString *)event {
    return ECommProductsSearched;
}

- (NSDictionary *)properties {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    if (_query != nil) {
        [tempDict setValue:_query forKey:KeyQuery];
    }
    return tempDict;
}

@end
