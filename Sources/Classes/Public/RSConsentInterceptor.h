//
//  RSConsentInterceptor.h
//  Rudder
//
//  Created by Pallab Maiti on 16/01/23.
//

#import <Foundation/Foundation.h>
#import "RSServerDestination.h"

NS_ASSUME_NONNULL_BEGIN

@class RSServerDestination;

@protocol RSConsentInterceptor

- (NSDictionary <NSString *, NSNumber *> * __nullable)filterConsentedDestinations:(NSArray <RSServerDestination *> *)destinations;

@end

NS_ASSUME_NONNULL_END
