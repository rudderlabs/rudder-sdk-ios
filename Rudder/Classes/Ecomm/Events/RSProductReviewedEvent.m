//
//  ProductReviewedEvent.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSProductReviewedEvent.h"
#import "RSECommerceParamNames.h"

@implementation ProductReviewedEvent

- (instancetype)withProduct:(RSECommerceProduct *)product {
    _product = product;
    return self;
}

- (instancetype)withReviewId:(NSString *)reviewId {
    _reviewId = reviewId;
    return self;
}

- (instancetype)withReviewBody:(NSString *)reviewBody {
    _reviewBody = reviewBody;
    return self;
}

- (instancetype)withRating:(float)rating {
    _rating = rating;
    return self;
}

- (NSString *)event {
    return ECommProductReviewed;
}

- (NSDictionary *)properties {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_product != nil) {
        [tempDict setValue:_product.productId forKey:KeyProductId];
    }
    if (_reviewId != nil) {
        [tempDict setValue:_reviewId forKey:KeyReviewId];
    }
    if (_reviewBody != nil) {
        [tempDict setValue:_reviewBody forKey:KeyReviewBody];
    }
    
    [tempDict setValue:[[NSNumber alloc] initWithFloat:_rating] forKey:KeyRating];
    return [tempDict copy];
}

@end
