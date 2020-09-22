//
//  RSMessageBuilder.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSMessageBuilder.h"
#import "RSElementCache.h"

@implementation RSMessageBuilder

- (instancetype) setPreviousId:(NSString *)previousId {
    if(message == nil) {
        message = [[RSMessage alloc] init];
    }
    message.previousId = previousId;
    return self;
}

-(instancetype) setGroupId:(NSString *)groupId {
    if(message == nil) {
        message = [[RSMessage alloc] init];
    }
    message.groupId = groupId;
    return self;
}

-(instancetype) setGroupTraits:(NSDictionary *)groupTraits {
    if(message == nil) {
        message = [[RSMessage alloc] init];
    }
    message.traits = groupTraits;
    return self;
}
- (instancetype) setEventName:(NSString *)eventName {
    if (message == nil) {
        message = [[RSMessage alloc] init];
    }
    message.event = eventName;
    return self;
}

- (instancetype) setUserId:(NSString *)userId {
    if (message == nil) {
        message = [[RSMessage alloc] init];
    }
    message.userId = userId;
    return self;
}

- (instancetype) setPropertyDict:(NSDictionary *)property {
    if (message == nil) {
        message = [[RSMessage alloc] init];
    }
    message.properties = property;
    return self;
}

- (instancetype) setProperty:(RSProperty *)property {
    if (message == nil) {
        message = [[RSMessage alloc] init];
    }
    message.properties = [property getPropertyDict];
    return self;
}

- (instancetype) setUserProperty:(NSDictionary<NSString *,NSObject *> *)userProperty {
    if (message == nil) {
        message = [[RSMessage alloc] init];
    }
    message.userProperties = userProperty;
    return self;
}

- (instancetype) setRSOption:(RSOption *)option {
    if (message == nil) {
        message = [[RSMessage alloc] init];
    }
    
    [message setRudderOption:option];
    
    return self;
}

- (instancetype)setTraits:(RSTraits *)traits {
    [RSElementCache updateTraits: traits];
    return self;
}

- (RSMessage*) build {
    if (message == nil) {
        message = [[RSMessage alloc] init];
    }
    
    return message;
}


@end
