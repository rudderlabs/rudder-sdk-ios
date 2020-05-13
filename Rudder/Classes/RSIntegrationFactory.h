//
//  RSIntegrationFactory.h
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 22/10/19.
//

#import <Foundation/Foundation.h>
#import "RSIntegration.h"
#import "RSClient.h"
#import "RSConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class RSClient;
@class RSConfig;

@protocol RSIntegrationFactory

- (id <RSIntegration>) initiate: (NSDictionary*) config
                             client: (RSClient*) client
                       rudderConfig: (RSConfig*) rudderConfig;
- (NSString*) key;

@end

NS_ASSUME_NONNULL_END
