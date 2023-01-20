//
//  RSConsentFilter.h
//  Rudder
//
//  Created by Pallab Maiti on 17/01/23.
//

#import <Foundation/Foundation.h>
#import "RSServerConfigSource.h"
#import "RSConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSConsentFilter : NSObject {
    RSServerConfigSource *serverConfig;
    RSConfig *rudderConfig;
}

+ (instancetype)initiate:(RSServerConfigSource *)serverConfig withRudderCofig:(RSConfig *)rudderConfig;
- (RSMessage *)applyConsents:(RSMessage *)message;

@end

NS_ASSUME_NONNULL_END
