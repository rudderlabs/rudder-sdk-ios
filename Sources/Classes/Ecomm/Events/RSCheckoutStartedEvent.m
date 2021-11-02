//
//  CheckoutStartedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSCheckoutStartedEvent.h"
#import "RSECommerceParamNames.h"

@implementation CheckoutStartedEvent

- (instancetype)withOrder:(RSECommerceOrder *)order {
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
