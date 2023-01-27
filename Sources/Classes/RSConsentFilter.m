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

- (instancetype)init:(NSArray <id<RSConsentInterceptor>> *)consentInterceptorList withServerConfig:(RSServerConfigSource *)serverConfig {
    self = [super init];
    if (self) {
        if (queue == nil) {
            queue = dispatch_queue_create("com.rudder.RSConsentFilter", NULL);
        }
        self->consentInterceptorList = [[NSMutableArray alloc] initWithArray:consentInterceptorList];
        self->serverConfig = serverConfig;
    }
    return self;
}


- (RSMessage *)applyConsents:(RSMessage *)message {
    if (consentInterceptorList == nil || consentInterceptorList.count == 0) {
        [RSLogger logInfo:@"RSConsentFilter: initiateConsents: No consent found"];
        return message;
    }
    __block RSMessage *updatedMessage = message;
    dispatch_sync(queue, ^{
        for (id<RSConsentInterceptor> consent in consentInterceptorList) {
            updatedMessage = [consent interceptWithServerConfig:serverConfig andMessage:updatedMessage];
        }
    });
    return updatedMessage;
}

@end
