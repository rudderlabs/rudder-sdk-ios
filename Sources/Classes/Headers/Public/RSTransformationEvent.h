//
//  RSTransformationEvent.h
//  Rudder
//
//  Created by Desu Sai Venkat on 04/07/23.
//

#import <Foundation/Foundation.h>
#import "RSMessage.h"

@interface RSTransformationEvent : NSObject

@property (atomic, readwrite) NSNumber* orderNo;
@property (atomic, readwrite) RSMessage *event;
@property (atomic, readwrite) NSArray<NSString *>* destinationIds;

- (NSDictionary *)toDict;
@end
