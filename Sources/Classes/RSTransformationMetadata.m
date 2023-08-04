//
//  RSTransformationMetadata.m
//  Rudder
//
//  Created by Desu Sai Venkat on 04/07/23.
//

#import "RSTransformationMetadata.h"

@implementation RSTransformationMetadata

- (NSDictionary *)toDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"Custom-Authorization"] = self.customAuthorization;
    return dict;
}

@end
