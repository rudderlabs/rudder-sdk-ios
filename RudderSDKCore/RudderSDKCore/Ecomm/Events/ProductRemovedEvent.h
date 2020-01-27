//
//  ProductRemovedEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceProduct.h"
#import "ECommerceEvents.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductRemovedEvent : NSObject

@property (nonatomic, strong) ECommerceProduct *product;

- (instancetype) withProduct: (ECommerceProduct*) product;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
