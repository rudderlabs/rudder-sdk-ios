//
//  OrderCancelledEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "OrderCancelledEvent.h"

@implementation OrderCancelledEvent

- (instancetype)withOrder:(ECommerceOrder *)order {
    _order = order;
    return self;
}

- (NSString *)event {
    return ECommOrderCancelled;
}

- (NSDictionary *)properties {
    if (_order == nil) {
        return @{};
    } else {
        return [_order dict];
    }
}


@end
