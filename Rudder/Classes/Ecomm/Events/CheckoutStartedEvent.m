//
//  CheckoutStartedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "CheckoutStartedEvent.h"
#import "ECommerceParamNames.h"

@implementation CheckoutStartedEvent

- (instancetype)withOrder:(ECommerceOrder *)order {
    _order = order;
    return self;
}

- (NSString *)event {
    return ECommCheckoutStarted;
}

- (NSDictionary *)properties {
    if (_order == nil) {
        return @{};
    } else {
        return [_order dict];
    }
}

@end
