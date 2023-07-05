//
//  RSTransformationEvent.m
//  Rudder
//
//  Created by Desu Sai Venkat on 04/07/23.
//

#import "RSTransformationEvent.h"

@implementation RSTransformationEvent

- (NSDictionary *)toDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"orderNo"] = self.orderNo;
    dict[@"event"] = [self.event dict];
    dict[@"destinationIds"] = self.destinationIds;
    return dict;
}

@end
