//
//  RSECommerceFilterBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceFilterBuilder : NSObject

@property (nonatomic, strong) RSECommerceFilter *filter;

- (instancetype) withType: (NSString*) type;
- (instancetype) withValue: (NSString*) value;
- (RSECommerceFilter*) build;

@end

NS_ASSUME_NONNULL_END
