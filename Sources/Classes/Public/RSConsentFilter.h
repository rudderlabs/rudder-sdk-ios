//
//  RSConsentFilter.h
//  Rudder
//
//  Created by Pallab Maiti on 17/01/23.
//

#import <Foundation/Foundation.h>
#import "RSServerConfigSource.h"
#import "RSConsentInterceptor.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSConsentFilter : NSObject {
    NSMutableArray <id<RSConsentInterceptor>> *consentInterceptorList;
    RSServerConfigSource *serverConfig;
}

+ (instancetype)initiate:(NSArray <id<RSConsentInterceptor>> *)consentInterceptorList withServerConfig:(RSServerConfigSource *)serverConfig;
- (RSMessage *)applyConsents:(RSMessage *)message;

@end

NS_ASSUME_NONNULL_END
