//
//  ProductClickedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ProductClickedEvent.h"

@implementation ProductClickedEvent

- (instancetype)withProduct:(ECommerceProduct *)product {
    _product = product;
    return self;
}

- (NSString *)event {
    return ECommProductClicked;
}

- (NSDictionary *)properties {
    if (_product == nil) {
        return @{};
    } else {
        return [_product dict];
    }
}

@end
