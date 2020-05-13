//
//  RSClient.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSClient.h"
#import "RSEventRepository.h"
#import "RSMessageBuilder.h"
#import "RSElementCache.h"
#import "RSMessageType.h"
#import "RSLogger.h"

static RSClient *_instance = nil;
static RSEventRepository *_repository = nil;

@implementation RSClient

+ (instancetype) getInstance {
    return _instance;
}

+ (instancetype) getInstance:(NSString *)writeKey {
    return [RSClient getInstance:writeKey config:[[RSConfig alloc] init]];
}

+ (instancetype) getInstance: (NSString *) writeKey config: (RSConfig*) config {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init];
            _repository = [RSEventRepository initiate:writeKey config:config];
        });
    }
    return _instance;
}

- (void) trackMessage:(RSMessage *)message {
    [self dumpInternal:message type:RSTrack];
}

- (void) dumpInternal:(RSMessage *)message type:(NSString*) type {
    if (_repository != nil && message != nil) {
        if (type == RSIdentify) {
            [RSElementCache updateTraitsDict:message.context.traits];
            [RSElementCache persistTraits];
        }
        
        message.type = type;
        [_repository dump:message];
    }
}

- (void)trackWithBuilder:(RSMessageBuilder *)builder{
    [self dumpInternal:[builder build] type:RSTrack];
}

- (void)track:(NSString *)eventName {
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:eventName];
    [self dumpInternal:[builder build] type:RSTrack];
}

- (void)track:(NSString *)eventName properties:(NSDictionary<NSString *,NSObject *> *)properties {
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:eventName];
    [builder setPropertyDict:properties];
    [self dumpInternal:[builder build] type:RSTrack];
}

- (void)track:(NSString *)eventName properties:(NSDictionary<NSString *,NSObject *> *)properties options:(RSOption *)options {
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:eventName];
    [builder setPropertyDict:properties];
    [builder setRSOption:options];
    [self dumpInternal:[builder build] type:RSTrack];
}

- (void) screenWithMessage:(RSMessage *)message {
    [self dumpInternal:message type:RSScreen];
}

- (void)screenWithBuilder:(RSMessageBuilder *)builder {
    [self dumpInternal:[builder build] type:RSScreen];
}

- (void)screen:(NSString *)screenName {
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    NSMutableDictionary *property = [[NSMutableDictionary alloc] init];
    [property setValue:screenName forKey:@"name"];
    [builder setEventName:screenName];
    [builder setPropertyDict:property];
    [self dumpInternal:[builder build] type:RSScreen];
}

- (void)screen:(NSString *)screenName properties:(NSDictionary<NSString *,NSObject *> *)properties {
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:screenName];
    [builder setPropertyDict:properties];
    [self dumpInternal:[builder build] type:RSScreen];
}

- (void)screen:(NSString *)screenName properties:(NSDictionary<NSString *,NSObject *> *)properties options:(RSOption *)options {
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:screenName];
    [builder setPropertyDict:properties];
    [builder setRSOption:options];
    [self dumpInternal:[builder build] type:RSScreen];
}

- (void)group:(NSString *)groupId{
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setGroupId:groupId];
    [self dumpInternal:[builder build] type:RSGroup];
}

- (void)group:(NSString *)groupId traits:(NSDictionary *)traits {
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setGroupId:groupId];
    [builder setGroupTraits:traits];
    [self dumpInternal:[builder build] type:RSGroup];
}

- (void)group:(NSString *)groupId traits:(NSDictionary *)traits options:(RSOption *)options {
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setGroupId:groupId];
    [builder setGroupTraits:traits];
    [builder setRSOption:options];
    [self dumpInternal:[builder build] type:RSGroup];
}

- (void)alias:(NSString *)newId {
    [self alias:newId options:nil];
}

- (void) alias:(NSString *)newId options:(RSOption *) options {
    RSMessageBuilder *builder =[[RSMessageBuilder alloc] init];
    [builder setUserId:newId];
    [builder setRSOption:options];
    
    RSContext *rc = [RSElementCache getContext];
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
    
    [RSElementCache updateTraitsDict:traits];
    [RSElementCache persistTraits];
    
    RSMessage *message = [builder build];
    [message updateTraitsDict:traits];
    
    [self dumpInternal:message type:RSAlias];
}

- (void) pageWithMessage:(RSMessage *)message {
    [RSLogger logWarn:@"Page call is no more supported for iOS source"];
}

- (void) identifyWithMessage:(RSMessage *)message {
    [self dumpInternal:message type:RSIdentify];
}

- (void)identifyWithBuilder:(RSMessageBuilder *)builder {
    [self identifyWithMessage:[builder build]];
}

- (void)identify:(NSString*)userId {
    RSTraits* traitsCopy = [[RSTraits alloc] init];
    [traitsCopy setUserId:userId];
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:RSIdentify];
    [builder setUserId:userId];
    [builder setTraits:traitsCopy];
    [self dumpInternal:[builder build] type:RSIdentify];
}

- (void)identify:(NSString *)userId traits:(NSDictionary *)traits {
    RSTraits* traitsObj = [[RSTraits alloc] initWithDict: traits];
    [traitsObj setUserId:userId];
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:RSIdentify];
    [builder setUserId:userId];
    [builder setTraits:traitsObj];
    [self dumpInternal:[builder build] type:RSIdentify];
}

- (void)identify:(NSString *)userId traits:(NSDictionary *)traits options:(NSDictionary *)options {
    RSTraits *traitsObj = [[RSTraits alloc] initWithDict:traits];
    [traitsObj setUserId:userId];
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:RSIdentify];
    [builder setUserId:userId];
    [builder setTraits:traitsObj];
    RSOption *optionsObj = [[RSOption alloc] initWithDict:options];
    [builder setRSOption:optionsObj];
    [self dumpInternal:[builder build] type:RSIdentify];
}

- (void)reset {
    [RSElementCache reset];
    if (_repository != nil) {
        [_repository reset];
    }
}

- (NSString*)getAnonymousId {
    // returns anonymousId
    return [RSElementCache getContext].device.identifier;
}

- (RSContext*) getContext {
    return [RSElementCache getContext];
}

- (RSConfig*)configuration {
    if (_repository == nil) {
        return nil;
    }
    return [_repository getConfig];
}

+ (instancetype)sharedInstance {
    return _instance;
}

@end
