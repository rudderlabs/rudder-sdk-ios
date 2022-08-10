//
//  RSNetworkManager.h
//  Rudder
//
//  Created by Desu Sai Venkat on 09/08/22.
//  Copyright © 2022 Rudder Labs India Pvt Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSLogger.h"
#import "RSConfig.h"
#import "RSContext.h"


typedef enum {
    NETWORKERROR =1,
    NETWORKSUCCESS =0,
    WRONGWRITEKEY =2
} NETWORKSTATE;

typedef enum {
    BATCH_ENDPOINT = 0,
    TRANSFORM_ENDPOINT = 1
} ENDPOINT;

NSString* const STATUS = @"STATUS";
NSString* const RESPONSE = @"RESPONSE";

@interface RSNetworkManager : NSObject {
    RSConfig* config;
    NSString* authToken;
    NSString* anonymousIdToken;
    NSLock* networkLock;
}

- (instancetype)initWithConfig:(RSConfig *) config andAuthToken:(NSString *) authToken andAnonymousIdToken:(NSString *) anonymousIdToken;
- (NSDictionary<NSString*, NSString*>*) sendNetworkRequest: (NSString*) payload toEndpoint:(ENDPOINT) endpoint;
@end
