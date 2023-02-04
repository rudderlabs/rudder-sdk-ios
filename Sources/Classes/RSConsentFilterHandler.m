//
//  RSConsentFilterHandler.m
//  Rudder
//
//  Created by Pallab Maiti on 17/01/23.
//

#import "RSConsentFilterHandler.h"
#import "RSLogger.h"
#import "RSConsentFilter.h"

@implementation RSConsentFilterHandler

static RSConsentFilterHandler* _instance;
static dispatch_queue_t queue;


+ (instancetype)initiate:(id<RSConsentFilter>)consentFilter withServerConfig:(RSServerConfigSource *)serverConfig {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [[self alloc] init:consentFilter withServerConfig:serverConfig];
        });
    }
    return _instance;
}

- (instancetype)init:(id<RSConsentFilter>)consentFilter withServerConfig:(RSServerConfigSource *)serverConfig {
    self = [super init];
    if (self) {
        if (queue == nil) {
            queue = dispatch_queue_create("com.rudder.RSConsentFilter", NULL);
        }
        self->serverConfig = serverConfig;
        self->consentFilter = consentFilter;
        [self updateConsentedIntegrationsMap];
    }
    return self;
}

- (void)updateConsentedIntegrationsMap {
    __block NSDictionary <NSString *, NSNumber *> *list;
    dispatch_sync(queue, ^{
        list = [consentFilter filterConsentedDestinations:serverConfig.destinations];
    });
    consentedIntegrationsMap = list;
}

- (BOOL)isFactoryConsented:(NSString *)factoryKey {
    if (consentedIntegrationsMap == nil) {
        return YES;
    }
    if (consentedIntegrationsMap[factoryKey]) {
        return [consentedIntegrationsMap[factoryKey] boolValue];
    }
    return YES;
}

@end
