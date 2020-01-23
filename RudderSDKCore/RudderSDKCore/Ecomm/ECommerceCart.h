//
//  ECommerceCart.h
//  Adjust
//
//  Created by Arnab Pal on 22/01/20.
//

#import <Foundation/Foundation.h>
#import "ECommerceProduct.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECommerceCart : NSObject

@property (nonatomic, strong) NSString* cartId;
@property (nonatomic, strong) NSMutableArray<ECommerceProduct*>* products;

- (void) setProduct:(ECommerceProduct *)product;

- (NSDictionary*) dict;

@end

NS_ASSUME_NONNULL_END
