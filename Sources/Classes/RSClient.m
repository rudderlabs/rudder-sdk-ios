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
#import "RSMetricsReporter.h"

static RSClient *_instance = nil;
static RSEventRepository *_repository = nil;
static RSUserSession *_userSession = nil;
static RSOption* _defaultOptions = nil;
static NSString* _deviceToken = nil;

@implementation RSClient

+ (instancetype) getInstance {
    return _instance;
}

+ (instancetype)getInstance:(NSString *)writeKey {
    return [self initiate:writeKey config:nil options:nil];
}

+ (instancetype)getInstance:(NSString *)writeKey config:(RSConfig*)config options:(RSOption*)options {
    return [self initiate:writeKey config:config options:options];
}

+ (instancetype)getInstance:(NSString *)writeKey config:(RSConfig*)config {
    return [self initiate:writeKey config:config options:nil];
}

+ (instancetype)initiate:(NSString *)writeKey config:(RSConfig * __nullable)config options:(RSOption * __nullable)options {
    if ([writeKey length] == 0) {
        [RSLogger logError:WRITE_KEY_ERROR];
    }
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init];
            if (options != nil) {
                _defaultOptions = options;
                _instance->_options = options;
            }
            RSConfig *_config = (config != nil) ? config : [[RSConfig alloc] init];
            _repository = [RSEventRepository initiate:writeKey config:_config client:_instance options:options];
            if(_deviceToken != nil && [_deviceToken length] != 0) {
                [_instance.context putDeviceToken:_deviceToken];
            }
        });
    }
    return _instance;
}

- (void) trackMessage:(RSMessage *)message {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    [self dumpInternal:message type:RSTrack];
}

- (void) dumpInternal:(RSMessage *)message type:(NSString*) type {
    // Session Tracking
    if (_repository != nil && message != nil) {
        message.type = type;
        [_repository dump:message];
    }
}

- (void)trackWithBuilder:(RSMessageBuilder *)builder{
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    [self dumpInternal:[builder build] type:RSTrack];
}

- (void)track:(NSString *)eventName {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:eventName];
    [self dumpInternal:[builder build] type:RSTrack];
}

- (void)track:(NSString *)eventName properties:(NSDictionary<NSString *,NSObject *> *)properties {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:eventName];
    [builder setPropertyDict:properties];
    [self dumpInternal:[builder build] type:RSTrack];
}

- (void)track:(NSString *)eventName properties:(NSDictionary<NSString *,NSObject *> *)properties options:(RSOption *)options {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:eventName];
    [builder setPropertyDict:properties];
    [builder setRSOption:options];
    [self dumpInternal:[builder build] type:RSTrack];
}

- (void) screenWithMessage:(RSMessage *)message {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    [self dumpInternal:message type:RSScreen];
}

- (void)screenWithBuilder:(RSMessageBuilder *)builder {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    [self dumpInternal:[builder build] type:RSScreen];
}

- (void)screen:(NSString *)screenName {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    NSMutableDictionary *property = [[NSMutableDictionary alloc] init];
    [property setValue:screenName forKey:@"name"];
    [builder setEventName:screenName];
    [builder setPropertyDict:property];
    [self dumpInternal:[builder build] type:RSScreen];
}

- (void)screen:(NSString *)screenName properties:(NSDictionary<NSString *,NSObject *> *)properties {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    NSMutableDictionary *property;
    if (properties == nil) {
        property = [[NSMutableDictionary alloc] init];
    } else {
        property = [properties mutableCopy];
    }
    [property setValue:screenName forKey:@"name"];
    [builder setEventName:screenName];
    [builder setPropertyDict:property];
    [self dumpInternal:[builder build] type:RSScreen];
}

- (void)screen:(NSString *)screenName properties:(NSDictionary<NSString *,NSObject *> *)properties options:(RSOption *)options {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    NSMutableDictionary *property;
    if (properties == nil) {
        property = [[NSMutableDictionary alloc] init];
    } else {
        property = [properties mutableCopy];
    }
    [property setValue:screenName forKey:@"name"];
    [builder setEventName:screenName];
    [builder setPropertyDict:property];
    [builder setRSOption:options];
    [self dumpInternal:[builder build] type:RSScreen];
}

- (void)group:(NSString *)groupId{
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setGroupId:groupId];
    [self dumpInternal:[builder build] type:RSGroup];
}

- (void)group:(NSString *)groupId traits:(NSDictionary *)traits {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setGroupId:groupId];
    [builder setGroupTraits:traits];
    [self dumpInternal:[builder build] type:RSGroup];
}

- (void)group:(NSString *)groupId traits:(NSDictionary *)traits options:(RSOption *)options {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setGroupId:groupId];
    [builder setGroupTraits:traits];
    [builder setRSOption:options];
    [self dumpInternal:[builder build] type:RSGroup];
}

- (void)alias:(NSString *)newId {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    [self alias:newId options:nil];
}

- (void) alias:(NSString *)newId options:(RSOption *) options {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    RSContext *rc = [RSElementCache getContext];
    NSMutableDictionary<NSString*,NSObject*>* traits = [rc.traits mutableCopy];
    
    NSObject *prevId = [traits objectForKey:@"userId"];
    if(prevId == nil) {
        prevId =[traits objectForKey:@"id"];
    }
    
    traits[@"id"] = newId;
    traits[@"userId"] = newId;
    
    RSMessageBuilder *builder =[[RSMessageBuilder alloc] init];
    [builder setUserId:newId];
    [builder setRSOption:options];
    
    if (prevId != nil) {
        [builder setPreviousId:[NSString stringWithFormat:@"%@", prevId]];
    }
    
    
    RSMessage *message = [builder build];
    [message updateTraitsDict:traits];
    
    [self dumpInternal:message type:RSAlias];
}

- (void) pageWithMessage:(RSMessage *)message {
    [RSLogger logWarn:@"Page call is no more supported for iOS source"];
}

- (void) identifyWithMessage:(RSMessage *)message {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    [self dumpInternal:message type:RSIdentify];
}

- (void)identifyWithBuilder:(RSMessageBuilder *)builder {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    [self identifyWithMessage:[builder build]];
}

- (void)identify:(NSString*)userId {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    RSTraits* traitsCopy = [[RSTraits alloc] init];
    [traitsCopy setUserId:userId];
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:RSIdentify];
    [builder setUserId:userId];
    [builder setTraits:traitsCopy];
    [self dumpInternal:[builder build] type:RSIdentify];
}

- (void)identify:(NSString *)userId traits:(NSDictionary *)traits {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    traits = [traits mutableCopy];
    RSTraits* traitsObj = [[RSTraits alloc] initWithDict: traits];
    [traitsObj setUserId:userId];
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:RSIdentify];
    [builder setUserId:userId];
    [builder setTraits:traitsObj];
    [self dumpInternal:[builder build] type:RSIdentify];
}

- (void)identify:(NSString *)userId traits:(NSDictionary *)traits options:(RSOption *)options {
    if ([RSClient getOptStatus]) {
        [self reportDiscardedEvent];
        return;
    }
    traits = [traits mutableCopy];
    RSTraits *traitsObj = [[RSTraits alloc] initWithDict:traits];
    [traitsObj setUserId:userId];
    RSMessageBuilder *builder = [[RSMessageBuilder alloc] init];
    [builder setEventName:RSIdentify];
    [builder setUserId:userId];
    [builder setTraits:traitsObj];
    [builder setExternalIds:options];
    [builder setRSOption:options];
    RSMessage *message = [builder build];
    [self dumpInternal: message type:RSIdentify];
}

- (void)reset {
    [self reset:NO];
}

- (void) reset:(BOOL) clearAnonymousId {
    if(clearAnonymousId) {
        [[RSPreferenceManager getInstance] refreshAnonymousId];
    }
    [RSElementCache reset];
    if (_repository != nil) {
        [_repository reset];
    }
}

- (void)flush {
    if ([RSClient getOptStatus]) {
        return;
    }
    if (_repository != nil) {
        [_repository flush];
    }
}

+ (BOOL)getOptStatus {
    if (_repository == nil) {
        [RSLogger logError:@"SDK is not initialised. Hence dropping the event"];
        return true;
    }
    if ([_repository getOptStatus]) {
        [RSLogger logDebug:@"User Opted out for tracking the activity, hence dropping the event"];
        return true;
    }
    return false;
}

- (void)optOut:(BOOL) optOut {
    if (_repository != nil) {
        [_repository saveOptStatus:optOut];
        [RSLogger logInfo:[NSString stringWithFormat:@"optOut() flag is set to %@", optOut ? @"true" : @"false"]];
    }
    else {
        [RSLogger logError:@"SDK is not initialised. Hence aborting optOut API call"];
    }
}

- (void)reportDiscardedEvent {
    [RSMetricsReporter report:SDKMETRICS_EVENTS_DISCARDED forMetricType:COUNT withProperties:@{SDKMETRICS_TYPE: SDKMETRICS_OPT_OUT} andValue:1];
}

- (void)shutdown {
    // TODO: decide shutdown behavior
}

- (NSString*)getAnonymousId {
    return self.anonymousId;
}

- (NSString *)anonymousId {
    if ([RSClient getOptStatus]) {
        return nil;
    }
    return [RSElementCache getAnonymousId];
}

- (RSContext *)context {
    if ([RSClient getOptStatus]) {
        return nil;
    }
    return [RSElementCache getContext];
}

- (RSContext*) getContext {
    return self.context;
}

- (RSConfig *)config {
    if (_repository == nil) {
        return nil;
    }
    if ([RSClient getOptStatus]) {
        return nil;
    }
    return [_repository getConfig];
}

- (RSConfig*)configuration {
    return self.config;
}

- (void)trackLifecycleEvents:(NSDictionary *)launchOptions {
    if ([RSClient getOptStatus]) {
        return;
    }
    [_repository applicationDidFinishLaunchingWithOptions:launchOptions];
}

+ (instancetype)sharedInstance {
    return _instance;
}

+ (RSOption*) getDefaultOptions {
    return _defaultOptions;
}

- (RSOption *)defaultOptions {
    return self->_options;
}

+ (void)setAnonymousId: (NSString *__nullable) anonymousId {
    [self putAnonymousId:anonymousId];
}

+ (void)putAnonymousId:(NSString *_Nonnull)anonymousId {
    if(anonymousId != nil && [anonymousId length] != 0) {
        RSPreferenceManager *preferenceManager = [RSPreferenceManager getInstance];
        if ([preferenceManager getOptStatus]) {
            [RSLogger logDebug:@"User Opted out for tracking the activity, hence dropping the anonymousId"];
            return;
        }
        [preferenceManager saveAnonymousId:anonymousId];
        // If SDK is already initialized then we need to update the anonymousId in the cached context traits and anonymousId token
        if(_repository != nil)
        {
            [RSElementCache updateTraitsAnonymousId];
            [_repository setAnonymousIdToken];
        }
    }
}

+ (void)putDeviceToken:(NSString *_Nonnull)deviceToken {
    if(deviceToken != nil && [deviceToken length] != 0) {
        RSPreferenceManager *preferenceManager = [RSPreferenceManager getInstance];
        if ([preferenceManager getOptStatus]) {
            [RSLogger logDebug:@"User Opted out for tracking the activity, hence dropping the device token"];
            return;
        }
        if(_instance == nil) {
            _deviceToken = deviceToken;
            return;
        }
        [_instance.context putDeviceToken:deviceToken];
    }
}

+ (void)putAuthToken:(NSString *_Nonnull) authToken {
    if(authToken != nil && [authToken length] !=0) {
        RSPreferenceManager *preferenceManager = [RSPreferenceManager getInstance];
        if([preferenceManager getOptStatus]) {
            [RSLogger logDebug:@"User Opted out for tracking the activity, hence dropping the auth token"];
            return;
        }
        NSString* base64EncodedAuthToken = [RSUtils getBase64EncodedString:authToken];
        if(base64EncodedAuthToken != nil) {
            [preferenceManager saveAuthToken:base64EncodedAuthToken];
        }
    }
}

#pragma mark - Session Tracking

- (void)startSession {
    [self startSession:[RSUtils getTimeStampLong]];
}

- (void)startSession:(long)sessionId {
    if ([[NSString stringWithFormat:@"%ld", sessionId] length] < 10) {
        [RSLogger logError:[[NSString alloc] initWithFormat:@"RSClient: startSession: Length of the sessionId should be atleast 10: %ld", sessionId]];
        return;
    }
    if(_repository != nil) {
        [_repository startSession:sessionId];
    }
}

- (void)endSession {
    if(_repository != nil) {
        [_repository endSession];
    }
}

- (NSNumber * _Nullable)sessionId {
    return (_repository != nil) ? [_repository getSessionId] : nil;
}

@end
