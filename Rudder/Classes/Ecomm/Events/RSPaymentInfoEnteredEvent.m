//
//  PaymentInfoEnteredEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSPaymentInfoEnteredEvent.h"
#import "RSECommerceParamNames.h"

@implementation PaymentInfoEnteredEvent

- (instancetype)withCheckout:(RSECommerceCheckout *)checkout {
    _checkout = checkout;
    return self;
}

- (instancetype)withCheckoutId:(NSString *)checkoutId {
    _checkoutId = checkoutId;
    return self;
}

- (instancetype)withOrderId:(NSString *)orderId {
    _orderId = orderId;
    return self;
}

- (NSString *)event {
    return ECommPaymentInfoEntered;
}

- (NSDictionary *)properties {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_checkout != nil) {
        [tempDict setValue:_checkout.checkoutId forKey:KeyCheckoutId];
        [tempDict setValue:_checkout.orderId forKey:KeyOrderId];
    } else if (_checkoutId != nil && _orderId != nil) {
        [tempDict setValue:_checkoutId forKey:KeyCheckoutId];
        [tempDict setValue:_orderId forKey:KeyOrderId];
    }
    
    return [tempDict copy];
}

@end
