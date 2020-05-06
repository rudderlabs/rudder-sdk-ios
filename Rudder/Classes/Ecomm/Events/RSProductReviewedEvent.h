//
//  ProductReviewedEvent.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceEvents.h"
#import "ECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductReviewedEvent : NSObject

@property (nonatomic, strong) ECommerceProduct *product;
@property (nonatomic, strong) NSString *reviewId;
@property (nonatomic, strong) NSString *reviewBody;
@property (nonatomic) float rating;

- (instancetype) withProduct: (ECommerceProduct*) product;
- (instancetype) withReviewId: (NSString*) reviewId;
- (instancetype) withReviewBody: (NSString*) reviewBody;
- (instancetype) withRating: (float) rating;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
