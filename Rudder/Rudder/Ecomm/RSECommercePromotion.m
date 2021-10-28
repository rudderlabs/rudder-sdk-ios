//
//  RSECommercePromotion.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommercePromotion.h"

@implementation RSECommercePromotion

- (NSDictionary*) dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_promotionId != nil) {
        [tempDict setValue:_promotionId forKey:@"promotion_id"];
    }
    if (_creative != nil) {
        [tempDict setValue:_creative forKey:@"creative"];
    }
    if (_name != nil) {
        [tempDict setValue:_name forKey:@"name"];
    }
    if (_position != nil) {
        [tempDict setValue:_position forKey:@"position"];
    }
    
    return [tempDict copy];
}


@end
