//
//  RSNetworkResponse.h
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSNetworkEnums.h"


@interface RSNetworkResponse : NSObject

@property NSString* responsePayload;
@property NSString* errorPayload;
@property long statusCode;
@property (nonatomic, assign) NETWORKSTATE state;

-(instancetype) initWithResponsePayload:(NSString *) responsePayload andErrorPayload:(NSString *) errorPayload andStatusCode:(long) statusCode andNetworkState:(NETWORKSTATE) state;
@end
