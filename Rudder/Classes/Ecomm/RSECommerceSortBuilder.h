//
//  ECommerceSortBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceSort.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECommerceSortBuilder : NSObject

@property (nonatomic, strong) ECommerceSort *sort;

- (instancetype) withType: (NSString*) type;
- (instancetype) withValue: (NSString*) value;
- (ECommerceSort*) build;

@end

NS_ASSUME_NONNULL_END
