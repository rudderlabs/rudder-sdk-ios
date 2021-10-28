//
//  RSECommerceEvents.h
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceEvents : NSObject

extern NSString *const ECommProductsSearched;
extern NSString *const ECommProductListViewed;
extern NSString *const ECommProductListFiltered;
extern NSString *const ECommPromotionViewed;
extern NSString *const ECommPromotionClicked;
extern NSString *const ECommProductClicked;
extern NSString *const ECommProductViewed;
extern NSString *const ECommProductAdded;
extern NSString *const ECommProductRemoved;
extern NSString *const ECommCartViewed;
extern NSString *const ECommCheckoutStarted;
extern NSString *const ECommCheckoutStepViewed;
extern NSString *const ECommCheckoutStepCompleted;
extern NSString *const ECommPaymentInfoEntered;
extern NSString *const ECommOrderUpdated;
extern NSString *const ECommOrderCompleted;
extern NSString *const ECommOrderRefunded;
extern NSString *const ECommOrderCancelled;
extern NSString *const ECommCouponEntered;
extern NSString *const ECommCouponApplied;
extern NSString *const ECommCouponDenied;
extern NSString *const ECommCouponRemoved;
extern NSString *const ECommProductAddedToWishList;
extern NSString *const ECommProductRemovedFromWishList;
extern NSString *const ECommWishListProductAddedToCart;
extern NSString *const ECommProductShared;
extern NSString *const ECommCartShared;
extern NSString *const ECommProductReviewed;

@end

NS_ASSUME_NONNULL_END
