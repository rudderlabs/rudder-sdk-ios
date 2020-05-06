//
//  RSECommerceProduct.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceProduct : NSObject

@property (nonatomic, strong) NSString* productId;
@property (nonatomic, strong) NSString* sku;
@property (nonatomic, strong) NSString* category;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* brand;
@property (nonatomic, strong) NSString* variant;
@property (nonatomic) float price;
@property (nonatomic, strong) NSString* currency;
@property (nonatomic) float quantity;
@property (nonatomic, strong) NSString* coupon;
@property (nonatomic) int position;
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* imageUrl;

- (NSDictionary*) dict;

@end

NS_ASSUME_NONNULL_END
