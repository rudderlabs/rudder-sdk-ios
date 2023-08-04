//
//  RSEnums.h
//  Rudder
//
//  Created by Desu Sai Venkat on 25/10/22.
//

#ifndef RSEnums_h
#define RSEnums_h

typedef NS_ENUM(NSInteger, RSDataResidencyServer) {
  EU,
  US
};

typedef enum {
    ASCENDING,
    DESCENDING
} ORDER;

typedef enum {
    NETWORK_ERROR,
    NETWORK_SUCCESS,
    WRONG_WRITE_KEY,
    INVALID_URL,
    RESOURCE_NOT_FOUND,
    NETWORK_UNAVAILABLE,
    BAD_REQUEST
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

typedef enum {
    NOT_PROCESSED =0,
    DEVICE_MODE_PROCESSING_DONE =1,
    CLOUD_MODE_PROCESSING_DONE =2,
    COMPLETE_PROCESSING_DONE =3
} EVENT_PROCESSING_STATUS;

typedef enum {
    CLOUDMODE =2,
    DEVICEMODE =1,
    ALL = 3
} MODES;

typedef enum {
    DM_PROCESSED_PENDING =0,
    DM_PROCESSED_DONE =1,
} DM_PROCESSED;

typedef enum {
    ENABLED = YES,
    DISABLED = NO
} TRANSFORMATION_STATUS;

typedef enum {
    TRACK,
    SCREEN,
    ALIAS,
    IDENTIFY,
    GROUP
} MESSAGE_TYPE;

typedef enum {
    COUNT,
    GAUGE
} METRIC_TYPE;

#endif /* RSEnums_h */
