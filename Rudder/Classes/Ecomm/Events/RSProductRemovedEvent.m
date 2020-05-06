//
//  ProductRemovedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ProductRemovedEvent.h"

@implementation ProductRemovedEvent

- (instancetype)withProduct:(ECommerceProduct *)product {
    _product = product;
    return self;
}

- (NSString *)event {
    return ECommProductRemoved;
}

- (NSDictionary *)properties {
    if (_product == nil) {
        return @{};
    } else {
        return [_product dict];
    }
}

@end
