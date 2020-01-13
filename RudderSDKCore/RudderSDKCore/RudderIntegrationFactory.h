//
//  RudderIntegrationFactory.h
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 22/10/19.
//

#import <Foundation/Foundation.h>
#import "RudderIntegration.h"
#import "RudderClient.h"
#import "RudderConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class RudderClient;
@class RudderConfig;

@protocol RudderIntegrationFactory

- (id <RudderIntegration>) initiate: (NSDictionary*) config
                             client: (RudderClient*) client
                       rudderConfig: (RudderConfig*) rudderConfig;
- (NSString*) key;

@end

NS_ASSUME_NONNULL_END
