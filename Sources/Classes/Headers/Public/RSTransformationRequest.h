//
//  RSTransformationRequest.h
//  Rudder
//
//  Created by Desu Sai Venkat on 03/07/23.


#import <Foundation/Foundation.h>
#import "RSTransformationEvent.h"
#import "RSTransformationMetadata.h"

@interface RSTransformationRequest : NSObject

@property (atomic, readwrite) RSTransformationMetadata *metadata;
@property (atomic, readwrite) NSMutableArray<RSTransformationEvent *> *batch;

- (NSDictionary *)toDict;
@end
