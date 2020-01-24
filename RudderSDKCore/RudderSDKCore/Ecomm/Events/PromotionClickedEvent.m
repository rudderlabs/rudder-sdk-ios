//
//  PromotionClickedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "PromotionClickedEvent.h"
#import "ECommerceParamNames.h"

@implementation PromotionClickedEvent

- (instancetype)withPromotion:(ECommercePromotion *)promotion {
    _promotion = promotion;
    return self;
}

- (NSString *)event {
    return ECommPromotionClicked;
}

- (NSDictionary *)properties {
    if (_promotion == nil) {
        return @{};
    } else {
        return [_promotion dict];
    }
}

@end
