//
//  RSECommerceCheckoutBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceCheckout.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceCheckoutBuilder : NSObject

@property (nonatomic, strong) RSECommerceCheckout* checkout;

- (instancetype) withCheckoutId: (NSString*) checkoutId;
- (instancetype) withOrderId: (NSString*) orderId;
- (instancetype) withStep: (int) step;
- (instancetype) withShippingMethod: (NSString*) shippingMethod;
- (instancetype) withPaymentMethod: (NSString*) paymentMethod;
- (RSECommerceCheckout*) build;

@end

NS_ASSUME_NONNULL_END
