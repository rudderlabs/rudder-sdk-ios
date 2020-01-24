//
//  PromotionClickedEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommercePromotion.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface PromotionClickedEvent : NSObject

@property (nonatomic, strong) ECommercePromotion *promotion;

- (instancetype) withPromotion: (ECommercePromotion*) promotion;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
