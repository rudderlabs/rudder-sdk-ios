//
//  RSECommerceSortBuilder.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceSort.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceSortBuilder : NSObject

@property (nonatomic, strong) RSECommerceSort *sort;

- (instancetype) withType: (NSString*) type;
- (instancetype) withValue: (NSString*) value;
- (RSECommerceSort*) build;

@end

NS_ASSUME_NONNULL_END
