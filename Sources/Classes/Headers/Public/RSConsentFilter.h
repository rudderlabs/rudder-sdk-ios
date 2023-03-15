//
//  RSConsentFilter.h
//  Rudder
//
//  Created by Pallab Maiti on 16/01/23.
//

#import <Foundation/Foundation.h>
#import "RSServerDestination.h"

NS_ASSUME_NONNULL_BEGIN

//@class RSServerDestination;

@protocol RSConsentFilter

- (NSDictionary <NSString *, NSNumber *> * __nullable)filterConsentedDestinations:(NSArray <RSServerDestination *> *)destinations;

@optional
- (NSDictionary <NSString *, NSNumber *> * __nullable)getConsentCategoriesDict;

@end

NS_ASSUME_NONNULL_END
