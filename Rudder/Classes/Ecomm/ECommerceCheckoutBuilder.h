//
//  ECommerceCheckoutBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceCheckout.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECommerceCheckoutBuilder : NSObject

@property (nonatomic, strong) ECommerceCheckout* checkout;

- (instancetype) withCheckoutId: (NSString*) checkoutId;
- (instancetype) withOrderId: (NSString*) orderId;
- (instancetype) withStep: (int) step;
- (instancetype) withShippingMethod: (NSString*) shippingMethod;
- (instancetype) withPaymentMethod: (NSString*) paymentMethod;
- (ECommerceCheckout*) build;

@end

NS_ASSUME_NONNULL_END
