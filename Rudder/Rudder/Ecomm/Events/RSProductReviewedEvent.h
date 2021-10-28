//
//  ProductReviewedEvent.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceEvents.h"
#import "RSECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface ProductReviewedEvent : NSObject

@property (nonatomic, strong) RSECommerceProduct *product;
@property (nonatomic, strong) NSString *reviewId;
@property (nonatomic, strong) NSString *reviewBody;
@property (nonatomic) float rating;

- (instancetype) withProduct: (RSECommerceProduct*) product;
- (instancetype) withReviewId: (NSString*) reviewId;
- (instancetype) withReviewBody: (NSString*) reviewBody;
- (instancetype) withRating: (float) rating;

- (nonnull NSString*) event;
- (nonnull NSDictionary*) properties;

@end

NS_ASSUME_NONNULL_END
