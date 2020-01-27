//
//  ProductViewedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "ProductViewedEvent.h"

@implementation ProductViewedEvent

- (instancetype)withProduct:(ECommerceProduct *)product {
    _product = product;
    return self;
}

- (NSString *)event {
    return ECommProductViewed;
}

- (NSDictionary *)properties {
    if (_product == nil) {
        return @{};
    } else {
        return [_product dict];
    }
}

@end
