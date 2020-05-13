//
//  ProductSearchedEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductSearchedEvent : NSObject

@property (nonatomic, strong) NSString* query;

- (instancetype) withQuery: (NSString*) query;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
