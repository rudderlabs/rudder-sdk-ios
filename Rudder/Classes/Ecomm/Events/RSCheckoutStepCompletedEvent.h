//
//  CheckoutStepCompletedEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceCheckout.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface CheckoutStepCompletedEvent : NSObject

@property (nonatomic, strong) ECommerceCheckout *checkout;

- (instancetype) withCheckout: (ECommerceCheckout*) checkout;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
