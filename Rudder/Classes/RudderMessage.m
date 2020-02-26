//
//  RudderMessage.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderMessage.h"
#import "RudderElementCache.h"
#import "Utils.h"

@implementation RudderMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messageId = [[NSString alloc] initWithFormat:@"%ld-%@", [Utils getTimeStampLong], [Utils getUniqueId]];
        _channel = @"mobile";
        _context = [RudderElementCache getContext];
        _originalTimestamp = [Utils getTimestamp];
        _anonymousId = [[NSString alloc] initWithFormat:@"%@", [_context.traits objectForKey:@"anonymousId"]];
        NSObject *userIdObj = [_context.traits objectForKey:@"userId"];
        if (userIdObj != nil) {
            _userId = [[NSString alloc] initWithFormat:@"%@", userIdObj];
        }
    }
    return self;
}

- (NSDictionary<NSString*, NSObject*>*) dict {
    NSMutableDictionary* tempDict = [[NSMutableDictionary alloc] init];
    
    [tempDict setValue:_messageId forKey:@"messageId"];
    [tempDict setValue:_channel forKey:@"channel"];
    [tempDict setValue:[_context dict] forKey:@"context"];
    [tempDict setValue:_type forKey:@"type"];
    [tempDict setValue:_action forKey:@"action"];
    [tempDict setValue:_originalTimestamp forKey:@"originalTimestamp"];
    [tempDict setValue:_anonymousId forKey:@"anonymousId"];
    if (_userId != nil) {
        [tempDict setValue:_userId forKey:@"userId"];
    }
    [tempDict setValue:_properties forKey:@"properties"];
    [tempDict setValue:_event forKey:@"event"];
    [tempDict setValue:_userProperties forKey:@"userProperties"];
    [tempDict setValue:_integrations forKey:@"integrations"];
    
    return [tempDict copy];
}

- (void)updateContext:(RudderContext *)context {
    if (context != nil) {
        self.context = context;
    }
}

- (void)updateTraits:(RudderTraits *)traits {
    [_context updateTraits:traits];
}
@end
