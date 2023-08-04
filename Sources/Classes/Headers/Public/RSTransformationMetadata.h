//
//  RSTransformationMetadata.h
//  Rudder
//
//  Created by Desu Sai Venkat on 04/07/23.
//

#import <Foundation/Foundation.h>

@interface RSTransformationMetadata : NSObject

@property (atomic, readwrite) NSString *customAuthorization;

-(NSDictionary *) toDict;


@end
