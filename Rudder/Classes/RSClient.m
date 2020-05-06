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
#import "RudderLogger.h"

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

-(void)groupWithMessage:(RudderMessage *)message {
    if(_repository != nil && message != nil){
        message.type = @"group";
        [_repository dump: message];
    }
}

-(void)groupWithBuilder:(RudderMessageBuilder *)builder {
    [self groupWithMessage:[builder build]];
    
}

- (void)group:(NSString *)groupId{
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder setGroupId:groupId];
    [self groupWithMessage:[builder build]];
}

- (void)group:(NSString *)groupId traits:(NSDictionary *)traits {
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder setGroupId:groupId];
    [builder setGroupTraits:traits];
    [self groupWithMessage:[builder build]];
}

- (void)group:(NSString *)groupId traits:(NSDictionary *)traits options:(RudderOption *)options {
    RudderMessageBuilder *builder = [[RudderMessageBuilder alloc] init];
    [builder setGroupId:groupId];
    [builder setGroupTraits:traits];
    [builder setRudderOption:options];
    [self groupWithMessage:[builder build]];
}

//-(void) aliasWithMessage:(RudderMessage *)message {
//    if(_repository != nil && message !=nil){
//        // update cached traits and persist
//        [RudderElementCache updateTraitsDict:message.context.traits];
//        [RudderElementCache persistTraits];
//        message.type = @"alias";
//        [_repository dump:message];
//    }
//}

//-(void) aliasWithBuilder:(RudderMessageBuilder *)builder {
//    [self aliasWithMessage:[builder build]];
//}

- (void)alias:(NSString *)newId {
    [self alias:newId options:nil];
}

- (void) alias:(NSString *)newId options:(RudderOption *) options {
    RudderMessageBuilder *builder =[[RudderMessageBuilder alloc] init];
    [builder setUserId:newId];
    [builder setRudderOption:options];
    
    RudderContext *rc = [RudderElementCache getContext];
    NSMutableDictionary<NSString*,NSObject*>* traits = rc.traits;

    NSObject *prevId = [traits objectForKey:@"userId"];
    if(prevId == nil) {
        prevId =[traits objectForKey:@"id"];
    }
    
    if (prevId != nil) {
        [builder setPreviousId:[NSString stringWithFormat:@"%@", prevId]];
    }
    traits[@"id"] = newId;
    traits[@"userId"] = newId;
    
    [RudderElementCache updateTraitsDict:traits];
    [RudderElementCache persistTraits];
    
    RudderMessage *message = [builder build];
    [message updateTraitsDict:traits];
    
    message.type = @"alias";
    if(_repository != nil && message !=nil){
        message.type = @"alias";
        [_repository dump:message];
    }
}

- (void) pageWithMessage:(RudderMessage *)message {
    if (_repository != nil && message != nil) {
        message.type = @"page";
        [_repository dump:message];
    }
}

- (void) identifyWithMessage:(RudderMessage *)message {
    if (message != nil) {
        // update cached traits and persist
        [RudderElementCache updateTraitsDict:message.context.traits];
        [RudderElementCache persistTraits];
        
        // set message type to identify
        message.type = @"identify";
        
        if (_repository != nil) {
            [_repository dump:message];
        }
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
    [RudderElementCache reset];
    if (_repository != nil) {
        [_repository reset];
    }
}

- (NSString*)getAnonymousId {
    // returns anonymousId
    return [RudderElementCache getContext].device.identifier;
}

- (RudderContext*) getContext {
    return [RudderElementCache getContext];
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
