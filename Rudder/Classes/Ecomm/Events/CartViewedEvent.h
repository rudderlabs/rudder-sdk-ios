//
//  CartViewedEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceCart.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface CartViewedEvent : NSObject

@property (nonatomic, strong) ECommerceCart *cart;

- (instancetype) withCart: (ECommerceCart*) cart;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
