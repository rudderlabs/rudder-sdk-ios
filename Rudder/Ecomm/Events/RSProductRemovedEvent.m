//
//  ProductRemovedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSProductRemovedEvent.h"

@implementation ProductRemovedEvent

- (instancetype)withProduct:(RSECommerceProduct *)product {
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
