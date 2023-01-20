//
//  RSConsentManager.m
//  Rudder
//
//  Created by Pallab Maiti on 17/01/23.
//

#import "RSConsentFilter.h"
#import "RSLogger.h"
#import "RSConsentInterceptor.h"

@implementation RSConsentFilter

static RSConsentFilter* _instance;
static dispatch_queue_t queue;

+ (instancetype)initiate:(RSServerConfigSource *)serverConfig withRudderCofig:(RSConfig *)rudderConfig {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init:serverConfig withRudderCofig:rudderConfig];
        });
    }
    return _instance;
}

- (instancetype)init:(RSServerConfigSource *)serverConfig withRudderCofig:(RSConfig *)rudderConfig {
    self = [super init];
    if (self) {
        if (queue == nil) {
            queue = dispatch_queue_create("com.rudder.RSConsentFilter", NULL);
        }
        self->serverConfig = serverConfig;
        self->rudderConfig = rudderConfig;
    }
    return self;
}


- (RSMessage *)applyConsents:(RSMessage *)message {
    message = [self applyNativeConsents:message];
    message = [self applyCustomConsents:message];
    return message;
}

- (RSMessage *)applyNativeConsents:(RSMessage *)message {
    if (rudderConfig == nil || rudderConfig.consents == nil || rudderConfig.consents.count == 0) {
        [RSLogger logInfo:@"RSConsentFilter: initiateConsents: No consent found"];
        return message;
    }
    __block RSMessage *updatedMessage = message;
    dispatch_sync(queue, ^{
        for (id<RSConsentInterceptor> consent in rudderConfig.consents) {
            updatedMessage = [consent interceptWithServerConfig:serverConfig andMessage:updatedMessage];
        }
    });
    return updatedMessage;
}

- (RSMessage *)applyCustomConsents:(RSMessage *)message {
    if (rudderConfig == nil || rudderConfig.customConsents == nil || rudderConfig.customConsents.count == 0) {
        [RSLogger logInfo:@"RSConsentFilter: initiateCustomConsents: No consent found"];
        return message;
    }
    __block RSMessage *updatedMessage = message;
    dispatch_sync(queue, ^{
        for (id<RSConsentInterceptor> consent in rudderConfig.customConsents) {
            updatedMessage = [consent interceptWithServerConfig:serverConfig andMessage:updatedMessage];
        }
    });
    return updatedMessage;
}

@end
