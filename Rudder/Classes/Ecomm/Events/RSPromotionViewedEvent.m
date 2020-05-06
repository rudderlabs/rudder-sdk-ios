//
//  PromotionViewedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSPromotionViewedEvent.h"
#import "RSECommerceParamNames.h"

@implementation PromotionViewedEvent

- (instancetype)withPromotion:(RSECommercePromotion *)promotion {
    _promotion = promotion;
    return self;
}

- (NSString *)event {
    return ECommPromotionViewed;
}

- (NSDictionary *)properties {
    if (_promotion == nil) {
        return @{};
    } else {
        return [_promotion dict];
    }
}

@end
