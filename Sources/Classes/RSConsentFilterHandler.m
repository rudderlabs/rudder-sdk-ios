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
        [self updateDeniedConsentIds:_consentFilter];
    }
    return self;
}

- (void)updateConsentedIntegrationsDict:(id<RSConsentFilter>)_consentFilter {
     dispatch_sync(queue, ^{
         consentedIntegrationsDict = [_consentFilter filterConsentedDestinations:serverConfig.destinations];
    });
}

- (void)updateDeniedConsentIds:(id<RSConsentFilter>)_consentFilter {
    dispatch_sync(queue, ^{
        id consentFilter = _consentFilter;
        if ([consentFilter respondsToSelector:@selector(getConsentCategoriesDict)]) {
            NSMutableArray <NSString *> *_deniedConsentIds = [[NSMutableArray alloc] init];
            [[_consentFilter getConsentCategoriesDict] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
                if (![obj boolValue]) {
                    [_deniedConsentIds addObject:key];
                }
            }];
            if (_deniedConsentIds != nil && [_deniedConsentIds count] > 0) {
                deniedConsentIds = _deniedConsentIds;
            }
        }
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
    if (deniedConsentIds == nil || [deniedConsentIds count] == 0 || message.context == nil) {
        return message;
    }
    [message.context setConsentData:deniedConsentIds];
    return message;
}

@end
