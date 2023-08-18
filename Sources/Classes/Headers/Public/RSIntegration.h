//
//  RSIntegration.h
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 22/10/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RSMessage;

@protocol RSIntegration<NSObject>

- (void) dump: (RSMessage*) message;
- (void) reset;
- (void) flush;

@end

NS_ASSUME_NONNULL_END
