//
//  RSECommerceProduct.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommerceProduct.h"

@implementation RSECommerceProduct

- (NSDictionary*) dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_productId != nil) {
        [tempDict setValue:_productId forKey:@"product_id"];
    }
    if (_sku != nil) {
        [tempDict setValue:_sku forKey:@"sku"];
    }
    if (_category != nil) {
        [tempDict setValue:_category forKey:@"category"];
    }
    if (_name != nil) {
        [tempDict setValue:_name forKey:@"name"];
    }
    if (_brand != nil) {
        [tempDict setValue:_brand forKey:@"brand"];
    }
    if (_variant != nil) {
        [tempDict setValue:_variant forKey:@"variant"];
    }
    [tempDict setValue:[[NSNumber alloc] initWithFloat:_price] forKey:@"price"];
    if (_currency != nil) {
        [tempDict setValue:_currency forKey:@"currency"];
    }
    [tempDict setValue:[[NSNumber alloc] initWithFloat:_quantity] forKey:@"quantity"];
    if (_coupon != nil) {
        [tempDict setValue:_coupon forKey:@"coupon"];
    }
    [tempDict setValue:[[NSNumber alloc] initWithInt:_position] forKey:@"position"];
    if (_url != nil) {
        [tempDict setValue:_url forKey:@"url"];
    }
    if (_imageUrl != nil) {
        [tempDict setValue:_imageUrl forKey:@"image_url"];
    }
    
    return [tempDict copy];
}


@end
