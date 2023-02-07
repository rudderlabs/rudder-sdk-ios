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
        [self updateConsentedIntegrationsDict:_consentFilter];
    }
    return self;
}

- (void)updateConsentedIntegrationsDict:(id<RSConsentFilter>)consentFilter {
     dispatch_sync(queue, ^{
         consentedIntegrationsDict = [consentFilter filterConsentedDestinations:serverConfig.destinations];
    });
}

- (NSArray <RSServerDestination *> *)filterDestinationList:(NSArray <RSServerDestination *> *)destinations {
    if (consentedIntegrationsDict == nil) {
        return destinations;
    }
    NSMutableArray <RSServerDestination *> *filteredList = [[NSMutableArray alloc] initWithArray:destinations];
    for (RSServerDestination *destination in destinations) {
        NSString *factoryKey = destination.destinationDefinition.displayName;
        dispatch_sync(queue, ^{
            if (consentedIntegrationsDict[factoryKey] && ![consentedIntegrationsDict[factoryKey] boolValue]) {
                [filteredList removeObject:destination];
            }
        });
    }
    return filteredList;
}

- (RSMessage *)applyConsents:(RSMessage *)message {
    if (message.integrations == nil || consentedIntegrationsDict == nil) {
        return message;
    }
    __block RSMessage *updatedMessage = message;
    __block NSMutableDictionary <NSString *, NSObject *> *consentedMessageIntegrationsDict = [[NSMutableDictionary alloc] initWithDictionary:message.integrations];
    dispatch_sync(queue, ^{
        [consentedIntegrationsDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
            if (![obj boolValue]) {
                [consentedMessageIntegrationsDict setObject:[NSNumber numberWithBool:false] forKey:key];
            }
        }];
        updatedMessage.integrations = consentedMessageIntegrationsDict;
    });
    return updatedMessage;
}

@end
