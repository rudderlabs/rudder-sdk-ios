//
//  OrderCompletedEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceOrder.h"
#import "RSECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface OrderCompletedEvent : NSObject

@property (nonatomic, strong) RSECommerceOrder *order;

- (instancetype) withOrder: (RSECommerceOrder*) order;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
