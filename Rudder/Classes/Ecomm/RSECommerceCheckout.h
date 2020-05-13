//
//  RSECommerceCheckout.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceCheckout : NSObject

@property (nonatomic, strong) NSString* checkoutId;
@property (nonatomic, strong) NSString* orderId;
@property (nonatomic) int step;
@property (nonatomic, strong) NSString* shippingMethod;
@property (nonatomic, strong) NSString* paymentMethod;

- (NSDictionary*) dict;

@end

NS_ASSUME_NONNULL_END
