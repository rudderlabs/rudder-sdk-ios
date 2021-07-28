//
//  OrderCompletedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSOrderCompletedEvent.h"

@implementation OrderCompletedEvent

- (instancetype)withOrder:(RSECommerceOrder *)order {
    _order = order;
    return self;
}

- (NSString *)event {
    return ECommOrderCompleted;
}

- (NSDictionary *)properties {
    if (_order == nil) {
        return @{};
    } else {
        return [_order dict];
    }
}

@end
