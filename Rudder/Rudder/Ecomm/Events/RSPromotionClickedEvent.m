//
//  PromotionClickedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSPromotionClickedEvent.h"
#import "RSECommerceParamNames.h"

@implementation PromotionClickedEvent

- (instancetype)withPromotion:(RSECommercePromotion *)promotion {
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
