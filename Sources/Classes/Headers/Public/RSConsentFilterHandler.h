//
//  RSConsentFilterHandler.h
//  Rudder
//
//  Created by Pallab Maiti on 17/01/23.
//

#import <Foundation/Foundation.h>
#import "RSServerConfigSource.h"
#import "RSConsentFilter.h"
#import "RSMessage.h"

NS_ASSUME_NONNULL_BEGIN

@class RSMessage;
@class RSServerConfigSource;

@interface RSConsentFilterHandler : NSObject {
    RSServerConfigSource *serverConfig;
    NSDictionary <NSString *, NSNumber *> *consentedIntegrationsDict;
    NSArray <NSString *> *deniedConsentIds;
}

+ (instancetype)initiate:(id<RSConsentFilter>)consentFilter withServerConfig:(RSServerConfigSource *)serverConfig;
- (RSMessage *)applyConsents:(RSMessage *)message;
- (NSArray <RSServerDestination *> *)filterDestinationList:(NSArray <RSServerDestination *> *)destinations;

@end

NS_ASSUME_NONNULL_END
