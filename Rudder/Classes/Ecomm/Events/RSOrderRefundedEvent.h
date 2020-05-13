//
//  OrderRefundedEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceOrder.h"
#import "RSECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface OrderRefundedEvent : NSObject

@property (nonatomic, strong) RSECommerceOrder *order;
@property (nonatomic, strong) NSMutableArray<RSECommerceProduct*> *products;
@property (nonatomic) float value;

- (instancetype) withOrder: (RSECommerceOrder*) order;
- (instancetype) withProduct: (RSECommerceProduct*) product;
- (instancetype) withProducts: (NSArray<RSECommerceProduct*>*) products;
- (instancetype) withRefundValue: (float) value;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
