//
//  RSECommerceCheckout.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommerceCheckout.h"

@implementation RSECommerceCheckout

- (NSDictionary *)dict {
    NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
    
    [tempDictionary setValue:_checkoutId forKey:@"checkout_id"];
    [tempDictionary setValue:_orderId forKey:@"order_id"];
    [tempDictionary setValue:[[NSNumber alloc] initWithInt:_step] forKey:@"step"];
    [tempDictionary setValue:_shippingMethod forKey:@"shipping_method"];
    [tempDictionary setValue:_paymentMethod forKey:@"payment_method"];

    return [tempDictionary copy];
}

@end
