//
//  PromotionViewedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "PromotionViewedEvent.h"
#import "ECommerceParamNames.h"

@implementation PromotionViewedEvent

- (instancetype)withPromotion:(ECommercePromotion *)promotion {
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
