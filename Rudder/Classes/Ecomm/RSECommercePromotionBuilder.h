//
//  RSECommercePromotionBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommercePromotion.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSECommercePromotionBuilder : NSObject

@property (nonatomic, strong) RSECommercePromotion *promotion;

- (instancetype) withPromotionId: (NSString*) promotionId;
- (instancetype) withCreative: (NSString*) creative;
- (instancetype) withName: (NSString*) name;
- (instancetype) withPosition: (NSString*) position;
- (RSECommercePromotion*) build;

@end

NS_ASSUME_NONNULL_END
