//
//  OrderUpdatedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSOrderUpdatedEvent.h"

@implementation OrderUpdatedEvent

- (instancetype)withOrder:(RSECommerceOrder *)order {
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
