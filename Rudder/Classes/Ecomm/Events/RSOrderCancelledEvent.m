//
//  OrderCancelledEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSOrderCancelledEvent.h"

@implementation OrderCancelledEvent

- (instancetype)withOrder:(RSECommerceOrder *)order {
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
