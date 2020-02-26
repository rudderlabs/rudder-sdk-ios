//
//  OrderUpdatedEvent.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "OrderUpdatedEvent.h"

@implementation OrderUpdatedEvent

- (instancetype)withOrder:(ECommerceOrder *)order {
    _order = order;
    return self;
}

- (NSString *)event {
    return ECommOrderUpdated;
}

- (NSDictionary *)properties {
    if (_order == nil) {
        return @{};
    } else {
        return [_order dict];
    }
}

@end
