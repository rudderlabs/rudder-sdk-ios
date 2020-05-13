//
//  PromotionClickedEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommercePromotion.h"
#import "RSECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface PromotionClickedEvent : NSObject

@property (nonatomic, strong) RSECommercePromotion *promotion;

- (instancetype) withPromotion: (RSECommercePromotion*) promotion;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
