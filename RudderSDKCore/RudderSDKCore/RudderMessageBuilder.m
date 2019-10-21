//
//  RudderMessageBuilder.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderMessageBuilder.h"
#import "RudderElementCache.h"

@implementation RudderMessageBuilder

- (instancetype) setEventName:(NSString *)eventName {
    if (message == nil) {
        message = [[RudderMessage alloc] init];
    }
    message.event = eventName;
    return self;
}

- (instancetype) setUserId:(NSString *)userId {
    if (message == nil) {
        message = [[RudderMessage alloc] init];
    }
    message.userId = userId;
    return self;
}

- (instancetype) setPropertyDict:(NSDictionary *)property {
    if (message == nil) {
        message = [[RudderMessage alloc] init];
    }
    message.properties = property;
    return self;
}

- (instancetype) setProperty:(RudderProperty *)property {
    if (message == nil) {
        message = [[RudderMessage alloc] init];
    }
    message.properties = [property getPropertyDict];
    return self;
}

- (instancetype) setUserProperty:(NSDictionary<NSString *,NSObject *> *)userProperty {
    if (message == nil) {
        message = [[RudderMessage alloc] init];
    }
    message.userProperties = userProperty;
    return self;
}

- (instancetype) setRudderOption:(RudderOption *)option {
    if (message == nil) {
        message = [[RudderMessage alloc] init];
    }
    
    return self;
}

- (instancetype)setTraits:(RudderTraits *)traits {
    [RudderElementCache updateTraits: traits];
    if (message == nil) {
        message = [[RudderMessage alloc] init];
    }
    [message updateTraits:traits];
    return self;
}

- (RudderMessage*) build {
    if (message == nil) {
        message = [[RudderMessage alloc] init];
    }
    
    return message;
}


@end
