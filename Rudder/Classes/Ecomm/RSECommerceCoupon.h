//
//  RSECommerceCoupon.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceCoupon : NSObject

@property (nonatomic, strong) NSString* cartId;
@property (nonatomic, strong) NSString* orderId;
@property (nonatomic, strong) NSString* couponId;
@property (nonatomic, strong) NSString* couponName;
@property (nonatomic) float discount;
@property (nonatomic, strong) NSString* reason;

- (NSDictionary*) dict;

@end

NS_ASSUME_NONNULL_END
