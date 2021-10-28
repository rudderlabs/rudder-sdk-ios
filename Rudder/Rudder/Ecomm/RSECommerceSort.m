//
//  RSECommerceSort.m
//  RSSDKCore
//
//  Created by Arnab Pal on 22/01/20.
//

#import "RSECommerceSort.h"

@implementation RSECommerceSort

- (NSDictionary*) dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    
    if (_type != nil) {
        [tempDict setValue:_type forKey:@"type"];
    }
    
    if (_value != nil) {
        [tempDict setValue:_value forKey:@"value"];
    }
    
    return [tempDict copy];
}


@end
