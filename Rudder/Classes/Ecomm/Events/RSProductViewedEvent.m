//
//  ProductViewedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSProductViewedEvent.h"

@implementation ProductViewedEvent

- (instancetype)withProduct:(RSECommerceProduct *)product {
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
