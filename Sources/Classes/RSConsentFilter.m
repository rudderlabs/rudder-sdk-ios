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


+ (instancetype)initiate:(id<RSConsentInterceptor>)consentInterceptor withServerConfig:(RSServerConfigSource *)serverConfig {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init:consentInterceptor withServerConfig:serverConfig];
        });
    }
    return _instance;
}

- (instancetype)init:(id<RSConsentInterceptor>)consentInterceptor withServerConfig:(RSServerConfigSource *)serverConfig {
    self = [super init];
    if (self) {
        if (queue == nil) {
            queue = dispatch_queue_create("com.rudder.RSConsentFilter", NULL);
        }
        self->serverConfig = serverConfig;
        self->consentInterceptor = consentInterceptor;
    }
    return self;
}

- (NSDictionary <NSString *, NSNumber *> * __nullable)getConsentedIntegrations {
    __block NSDictionary <NSString *, NSNumber *> *list;
    dispatch_sync(queue, ^{
        list = [consentInterceptor filterConsentedDestinations:serverConfig.destinations];
    });
    return list;
}

- (RSMessage *)applyConsents:(RSMessage *)message {
    __block RSMessage *updatedMessage = message;
    dispatch_sync(queue, ^{
        updatedMessage.integrations = [consentInterceptor filterConsentedDestinations:serverConfig.destinations];
    });
    return updatedMessage;
}

@end
