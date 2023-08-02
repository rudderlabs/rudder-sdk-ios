//
//  RSTransformationRequest.m
//  Rudder
//
//  Created by Desu Sai Venkat on 04/07/23.
//

#import "RSTransformationRequest.h"

@implementation RSTransformationRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        self.batch  = [[NSMutableArray alloc] init];
    }
    return self;
}


- (NSDictionary *)toDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"metadata"] = [self.metadata toDict];
    
    NSMutableArray *batchArray = [NSMutableArray array];
    for (RSTransformationEvent *transformationEvent in self.batch) {
        [batchArray addObject:[transformationEvent toDict]];
    }
    dict[@"batch"] = batchArray;

    return dict;
}

@end
