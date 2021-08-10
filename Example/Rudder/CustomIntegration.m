//
//  _CustomIntegration.m
//  Rudder_Example
//
//  Created by Abhishek Pandey on 09/08/21.
//  Copyright © 2021 arnabp92. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Rudder/Rudder.h>
#import "CustomIntegration.h"

@implementation CustomIntegration

- (instancetype) initWithConfig:(NSDictionary *)config withAnalytics:(RSClient *)client {
    if (self == [super init]) {
    }
    return self;
}

- (void) processRuderEvent:(nonnull RSMessage *)message {
    NSString *type = message.type;
    if ([type isEqualToString:@"identify"]) {
//        Do something
    } else if ([type isEqualToString:@"track"]) {
//        Do something
    } else if ([type isEqualToString:@"screen"]) {
//        Do something
    } else {
        [RSLogger logWarn:@"MessageType is not supported"];
    }
}

- (void) dump:(nonnull RSMessage *)message {
    [self processRuderEvent:message];
}

- (void) reset {
}

@end
