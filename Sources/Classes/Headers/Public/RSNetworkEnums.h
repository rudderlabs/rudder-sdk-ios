//
//  RSNetworkEnums.h
//  Rudder
//
//  Created by Desu Sai Venkat on 10/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#ifndef RSNetworkEnums_h
#define RSNetworkEnums_h

typedef enum {
    NETWORK_ERROR,
    NETWORK_SUCCESS,
    WRONG_WRITE_KEY,
    RESOURCE_NOT_FOUND
} NETWORKSTATE;

typedef enum {
    BATCH_ENDPOINT,
    TRANSFORM_ENDPOINT,
    SOURCE_CONFIG_ENDPOINT
} ENDPOINT;

typedef enum {
    GET,
    POST
} REQUEST_METHOD;

#endif /* RSNetworkEnums_h */
