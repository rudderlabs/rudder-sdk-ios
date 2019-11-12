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
#import "RudderElementCache.h"

static RudderClient *_instance = nil;
static EventRepository *_repository = nil;

@implementation RudderClient

+ (instancetype) getInstance {
    return _instance;
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

- (void)screen:(NSString *)screenName {
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    NSMutableDictionary *property = [[NSMutableDictionary alloc] init];
    [property setValue:screenName forKey:@"name"];
    [builder setEventName:screenName];
    [builder setPropertyDict:property];
    [self screenWithMessage:[builder build]];
}

- (void)screen:(NSString *)screenName properties:(NSDictionary<NSString *,NSObject *> *)properties {
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder setEventName:screenName];
    [builder setPropertyDict:properties];
    [self screenWithBuilder:builder];
}

- (void)screen:(NSString *)screenName properties:(NSDictionary<NSString *,NSObject *> *)properties options:(RudderOption *)options {
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder setEventName:screenName];
    [builder setPropertyDict:properties];
    [builder setRudderOption:options];
    [self screenWithBuilder:builder];
}

- (void)group:(NSString *)groupId{
    
}

- (void)group:(NSString *)groupId traits:(NSDictionary<NSString *,NSObject *> *)traits {
    
}

- (void)group:(NSString *)groupId traits:(NSDictionary<NSString *,NSObject *> *)traits options:(NSDictionary<NSString *,NSObject *> *)options {
    
}

- (void)alias:(NSString *)newId {
    
}

- (void)alias:(NSString *)newId options:(NSDictionary<NSString *,NSObject *> *)options {
    
}

- (void) pageWithMessage:(RudderMessage *)message {
    if (_repository != nil && message != nil) {
        message.type = @"page";
        [_repository dump:message];
    }
}

- (void) identifyWithMessage:(RudderMessage *)message {
    if (_repository != nil && message != nil) {
        message.type = @"identify";
        NSString *userId = message.context.traits.userId;
        if (userId != nil) {
            message.userId = userId;
        }
        [_repository dump:message];
    }
}

- (void)identifyWithBuilder:(RudderMessageBuilder *)builder {
    [self identifyWithMessage:[builder build]];
}

- (void)identify:(NSString*)userId {
    RudderTraits* traitsCopy = [[RudderTraits alloc] init];
    [traitsCopy setUserId:userId];
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder setEventName:@"identify"];
    [builder setUserId:userId];
    [builder setTraits:traitsCopy];
    [self identifyWithMessage:[builder build]];
}

- (void)identify:(NSString *)userId traits:(NSDictionary *)traits {
    RudderTraits* traitsObj = [[RudderTraits alloc] initWithDict: traits];
    [traitsObj setUserId:userId];
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder setEventName:@"identify"];
    [builder setUserId:userId];
    [builder setTraits:traitsObj];
    [self identifyWithMessage:[builder build]];
}

- (void)identify:(NSString *)userId traits:(NSDictionary *)traits options:(NSDictionary *)options {
    RudderTraits *traitsObj = [[RudderTraits alloc] initWithDict:traits];
    [traitsObj setUserId:userId];
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder setEventName:@"identify"];
    [builder setUserId:userId];
    [builder setTraits:traitsObj];
    RudderOption *optionsObj = [[RudderOption alloc] initWithDict:options];
    [builder setRudderOption:optionsObj];
    [self identifyWithMessage:[builder build]];
}

- (void)reset {
    
}

- (NSString*)getAnonymousId {
    // returns anonymousId
    return [RudderElementCache getContext].device.identifier;
}

- (RudderConfig*)configuration {
    if (_repository == nil) {
        return nil;
    }
    return [_repository getConfig];
}

+ (instancetype)sharedInstance {
    return _instance;
}

@end
