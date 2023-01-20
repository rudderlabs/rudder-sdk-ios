//
//  RSConsentInterceptor.h
//  Rudder
//
//  Created by Pallab Maiti on 16/01/23.
//

#import <Foundation/Foundation.h>
#import "RSMessage.h"
#import "RSServerConfigSource.h"

NS_ASSUME_NONNULL_BEGIN

@class RSClient;
@class RSConfig;

@protocol RSConsentInterceptor

- (RSMessage *)interceptWithServerConfig:(RSServerConfigSource *)serverConfig andMessage:(RSMessage *)message;

@end

NS_ASSUME_NONNULL_END
