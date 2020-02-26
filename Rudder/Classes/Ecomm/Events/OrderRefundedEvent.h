//
//  OrderRefundedEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceOrder.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface OrderRefundedEvent : NSObject

@property (nonatomic, strong) ECommerceOrder *order;
@property (nonatomic, strong) NSMutableArray<ECommerceProduct*> *products;
@property (nonatomic) float value;

- (instancetype) withOrder: (ECommerceOrder*) order;
- (instancetype) withProduct: (ECommerceProduct*) product;
- (instancetype) withProducts: (NSArray<ECommerceProduct*>*) products;
- (instancetype) withRefundValue: (float) value;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
