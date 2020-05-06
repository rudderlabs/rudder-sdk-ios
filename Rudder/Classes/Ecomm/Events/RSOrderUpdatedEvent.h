//
//  OrderUpdatedEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceOrder.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface OrderUpdatedEvent : NSObject

@property (nonatomic, strong) ECommerceOrder *order;

- (instancetype) withOrder: (ECommerceOrder*) order;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
