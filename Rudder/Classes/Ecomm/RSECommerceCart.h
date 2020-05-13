//
//  RSECommerceCart.h
//  Adjust
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "RSECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSECommerceCart : NSObject

@property (nonatomic, strong) NSString* cartId;
@property (nonatomic, strong) NSMutableArray<RSECommerceProduct*>* products;

- (void) setProduct:(RSECommerceProduct *)product;

- (NSDictionary*) dict;

@end

NS_ASSUME_NONNULL_END
