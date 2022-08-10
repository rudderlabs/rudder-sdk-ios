//
//  RSNetworkResponse.m
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import "RSNetworkResponse.h"

@implementation RSNetworkResponse

-(instancetype) initWithResponsePayload:(NSString *) responsePayload andErrorPayload:(NSString *) errorPayload andStatusCode:(long) statusCode andNetworkState:(NETWORKSTATE) state {
    self = [super init];
    if(self) {
        self->_responsePayload = responsePayload;
        self->_errorPayload = errorPayload;
        self->_statusCode = statusCode;
        self->_state = state;
    }
    return self;
}

@end
