//
//  RSECommercePromotionBuilder.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommercePromotionBuilder.h"

@implementation RSECommercePromotionBuilder

- (instancetype)withPromotionId:(NSString *)promotionId {
    [self _initiate];
    _promotion.promotionId = promotionId;
    return self;
}

- (instancetype)withCreative:(NSString *)creative {
    [self _initiate];
    _promotion.creative = creative;
    return self;
}

- (instancetype)withName:(NSString *)name {
    [self _initiate];
    _promotion.name = name;
    return self;
}

- (instancetype)withPosition:(NSString *)position {
    [self _initiate];
    _promotion.position = position;
    return self;
}

- (RSECommercePromotion *)build {
    [self _initiate];
    return _promotion;
}

- (void) _initiate {
    if (_promotion == nil) {
        _promotion = [[RSECommercePromotion alloc] init];
    }
}

@end
