//
//  ECommercePromotionBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommercePromotion.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECommercePromotionBuilder : NSObject

@property (nonatomic, strong) ECommercePromotion *promotion;

- (instancetype) withPromotionId: (NSString*) promotionId;
- (instancetype) withCreative: (NSString*) creative;
- (instancetype) withName: (NSString*) name;
- (instancetype) withPosition: (NSString*) position;
- (ECommercePromotion*) build;

@end

NS_ASSUME_NONNULL_END
