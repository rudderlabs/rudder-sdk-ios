//
//  RudderIntegrationFactory.h
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 22/10/19.
//

#import <Foundation/Foundation.h>
#import "RudderIntegration.h"
#import "RudderClient.h"


NS_ASSUME_NONNULL_BEGIN

@class RudderClient;

@protocol RudderIntegrationFactory

- (id <RudderIntegration>) initiate: (NSDictionary*) config client:(RudderClient*) client;
- (NSString*) key;

@end

NS_ASSUME_NONNULL_END
