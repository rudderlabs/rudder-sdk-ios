//
//  RudderClient.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderClient.h"
#import "EventRepository.h"
#import "RudderMessageBuilder.h"

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

- (void)trackMessage:(RudderMessage *)message {
    if (_repository != nil && message != nil) {
        message.type = @"track";
        [_repository dump:message];
    }
}

- (void)trackWithBuilder:(RudderMessageBuilder *)builder{
    [self trackMessage:[builder build]];
}

- (void)track:(NSString *)eventName {
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder setEventName:eventName];
    [self trackMessage:[builder build]];
}

- (void)track:(NSString *)eventName properties:(NSDictionary<NSString *,NSObject *> *)properties {
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder setEventName:eventName];
    [builder setPropertyDict:properties];
    [self trackMessage:[builder build]];
}

- (void)track:(NSString *)eventName properties:(NSDictionary<NSString *,NSObject *> *)properties options:(RudderOption *)options {
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder setEventName:eventName];
    [builder setPropertyDict:properties];
    [builder setRudderOption:options];
    [self trackMessage:[builder build]];
}

- (void) screenWithMessage:(RudderMessage *)message {
    if (_repository != nil && message != nil) {
        message.type = @"screen";
        [_repository dump:message];
    }
}

- (void)screenWithBuilder:(RudderMessageBuilder *)builder {
    [self screenWithMessage:[builder build]];
}

- (void) page:(RudderMessage *)message {
    if (_repository != nil && message != nil) {
        message.type = @"page";
        [_repository dump:message];
    }
}

- (void) identifyWithMessage:(RudderMessage *)message {
    if (_repository != nil && message != nil) {
        message.type = @"identify";
        [_repository dump:message];
    }
}

+ (instancetype)sharedInstance {
    return _instance;
}

@end
