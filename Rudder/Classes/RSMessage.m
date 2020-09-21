//
//  RSMessage.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSMessage.h"
#import "RSElementCache.h"
#import "RSUtils.h"

@implementation RSMessage

- (instancetype)init
{
    self = [super init];
    if (self) {
        _messageId = [[NSString alloc] initWithFormat:@"%ld-%@", [RSUtils getTimeStampLong], [RSUtils getUniqueId]];
        _channel = @"mobile";
        _context = [RSElementCache getContext];
        _originalTimestamp = [RSUtils getTimestamp];
        _previousId = nil;
        _groupId = nil;
        _traits = nil;
        _userProperties = nil;
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
    if (_previousId != nil) {
        [tempDict setValue:_previousId forKey:@"previousId"];
    }
    if (_groupId != nil) {
        [tempDict setValue:_groupId forKey:@"groupId"];
    }
    if (_traits != nil) {
        [tempDict setValue:[RSUtils serializeDict:_traits] forKey:@"traits"];
    }
    [tempDict setValue:_anonymousId forKey:@"anonymousId"];
    if (_userId != nil) {
        [tempDict setValue:_userId forKey:@"userId"];
    }
    if (_properties != nil) {
        [tempDict setValue:[RSUtils serializeDict:_properties] forKey:@"properties"];
    }
    [tempDict setValue:_event forKey:@"event"];
    if (_userProperties != nil) {
        [tempDict setValue:[RSUtils serializeDict:_userProperties] forKey:@"userProperties"];
    }
    [tempDict setValue:_integrations forKey:@"integrations"];
    
    return [tempDict copy];
}

- (void)updateContext:(RSContext *)context {
    if (context != nil) {
        self.context = context;
    }
}

- (void)updateTraits:(RSTraits *)traits {
    [_context updateTraits:traits];
}

- (void)updateTraitsDict:(NSMutableDictionary<NSString *,NSObject *>*)traits {
    [_context updateTraitsDict:traits];
}

- (void)setRudderOption:(RSOption *)option {
    _option = option;
}
@end
