//
//  ECommerceFilterBuilder.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECommerceFilterBuilder : NSObject

@property (nonatomic, strong) ECommerceFilter *filter;

- (instancetype) withType: (NSString*) type;
- (instancetype) withValue: (NSString*) value;
- (ECommerceFilter*) build;

@end

NS_ASSUME_NONNULL_END
