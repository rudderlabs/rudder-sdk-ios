//
//  RudderClient.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderClient.h"
#import "EventRepository.h"

static RudderClient *_instance = nil;
static EventRepository *_repository = nil;

@implementation RudderClient

+ (instancetype) getInstance:(NSString *)writeKey builder:(RudderConfigBuilder *)builder {
    return [RudderClient getInstance:writeKey config:[builder build]];
}

+ (instancetype) getInstance:(NSString *)writeKey {
    return [RudderClient getInstance:writeKey config:[[RudderConfig alloc] init]];
}

+ (instancetype) getInstance: (NSString *) writeKey config: (RudderConfig*) config {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init];
            _repository = [EventRepository initiate:writeKey config:config];
        });
    }
    return _instance;
}

- (void) track:(RudderMessage *)message {
    if (_repository != nil && message != nil) {
        message.type = @"track";
        [_repository dump:message];
    }
}

- (void) screen:(RudderMessage *)message {
    if (_repository != nil && message != nil) {
        message.type = @"screen";
        [_repository dump:message];
    }
}

- (void) page:(RudderMessage *)message {
    if (_repository != nil && message != nil) {
        message.type = @"page";
        [_repository dump:message];
    }
}

- (void) identify:(RudderMessage *)message {
    if (_repository != nil && message != nil) {
        message.type = @"identify";
        [_repository dump:message];
    }
}

@end
