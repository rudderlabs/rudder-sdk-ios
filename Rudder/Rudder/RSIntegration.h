//
//  RSIntegration.h
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 22/10/19.
//

#import <Foundation/Foundation.h>
#import "RSMessage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RSIntegration<NSObject>

- (void) dump: (RSMessage*) message;
- (void) reset;

@end

NS_ASSUME_NONNULL_END
