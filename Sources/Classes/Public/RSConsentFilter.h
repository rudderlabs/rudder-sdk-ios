//
//  RSConsentFilter.h
//  Rudder
//
//  Created by Pallab Maiti on 17/01/23.
//

#import <Foundation/Foundation.h>
#import "RSServerConfigSource.h"
#import "RSConsentInterceptor.h"
#import "RSIntegrationFactory.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSConsentFilter : NSObject {
    id<RSConsentInterceptor> consentInterceptor;
    RSServerConfigSource *serverConfig;
}

+ (instancetype)initiate:(id<RSConsentInterceptor>)consentInterceptor withServerConfig:(RSServerConfigSource *)serverConfig;
- (NSDictionary <NSString *, NSNumber *> * __nullable)getConsentedIntegrations;
- (RSMessage *)applyConsents:(RSMessage *)message;

@end

NS_ASSUME_NONNULL_END
