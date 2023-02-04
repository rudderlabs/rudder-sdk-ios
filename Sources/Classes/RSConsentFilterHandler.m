//
//  RSConsentFilterHandler.m
//  Rudder
//
//  Created by Pallab Maiti on 17/01/23.
//

#import "RSConsentFilterHandler.h"
#import "RSLogger.h"
#import "RSConsentFilter.h"

static RSConsentFilterHandler* _instance;
static dispatch_queue_t queue;

@implementation RSConsentFilterHandler

+ (instancetype)initiate:(id<RSConsentFilter>)consentFilter withServerConfig:(RSServerConfigSource *)serverConfig {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init:consentFilter withServerConfig:serverConfig];
        });
    }
    return _instance;
}

- (instancetype)init:(id<RSConsentFilter>)_consentFilter withServerConfig:(RSServerConfigSource *)_serverConfig {
    self = [super init];
    if (self) {
        if (queue == nil) {
            queue = dispatch_queue_create("com.rudder.RSConsentFilter", NULL);
        }
        self->serverConfig = _serverConfig;
        self->consentFilter = _consentFilter;
        [self updateConsentedIntegrationsDict];
    }
    return self;
}

- (void)updateConsentedIntegrationsDict {
     dispatch_sync(queue, ^{
         consentedIntegrationsDict = [consentFilter filterConsentedDestinations:serverConfig.destinations];
    });
}

- (BOOL)isFactoryConsented:(NSString *)factoryKey {
    if (consentedIntegrationsDict == nil) {
        return YES;
    }
    __block BOOL isConsented = YES;
    dispatch_sync(queue, ^{
        if (consentedIntegrationsDict[factoryKey]) {
            isConsented = [consentedIntegrationsDict[factoryKey] boolValue];
        }
    });
    return isConsented;
}

@end
