//
//  CheckoutStepViewedEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceCheckout.h"
#import "RSECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface CheckoutStepViewedEvent : NSObject

@property (nonatomic, strong) RSECommerceCheckout *checkout;

- (instancetype) withCheckout: (RSECommerceCheckout*) checkout;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
