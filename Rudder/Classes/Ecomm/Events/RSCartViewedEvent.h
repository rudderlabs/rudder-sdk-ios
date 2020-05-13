//
//  CartViewedEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceCart.h"
#import "RSECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface CartViewedEvent : NSObject

@property (nonatomic, strong) RSECommerceCart *cart;

- (instancetype) withCart: (RSECommerceCart*) cart;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
