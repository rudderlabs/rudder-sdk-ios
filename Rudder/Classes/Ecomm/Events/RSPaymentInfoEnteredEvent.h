//
//  PaymentInfoEnteredEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceCheckout.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface PaymentInfoEnteredEvent : NSObject

@property (nonatomic, strong) ECommerceCheckout *checkout;
@property (nonatomic, strong) NSString *checkoutId;
@property (nonatomic, strong) NSString *orderId;

- (instancetype) withCheckout: (ECommerceCheckout*) checkout;
- (instancetype) withCheckoutId: (NSString*) checkoutId;
- (instancetype) withOrderId: (NSString*) orderId;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
