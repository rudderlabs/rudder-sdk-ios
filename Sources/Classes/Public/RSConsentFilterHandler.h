//
//  RSConsentFilterHandler.h
//  Rudder
//
//  Created by Pallab Maiti on 17/01/23.
//

#import <Foundation/Foundation.h>
#import "RSServerConfigSource.h"
#import "RSConsentFilter.h"
#import "RSIntegrationFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSConsentFilterHandler : NSObject {
    id<RSConsentFilter> consentFilter;
    RSServerConfigSource *serverConfig;
    NSDictionary <NSString *, NSNumber *> *consentedIntegrationsDict;
}

+ (instancetype)initiate:(id<RSConsentFilter>)consentFilter withServerConfig:(RSServerConfigSource *)serverConfig;
- (BOOL)isFactoryConsented:(NSString *)factoryKey;
- (void)updateConsentedIntegrationsDict;

@end

NS_ASSUME_NONNULL_END
