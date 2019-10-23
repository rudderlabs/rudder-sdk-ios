//
//  RudderIntegration.h
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 22/10/19.
//

#import <Foundation/Foundation.h>
#import "RudderMessage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RudderIntegration<NSObject>

- (void) dump: (RudderMessage*) message;

@end

NS_ASSUME_NONNULL_END
