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
#import "RSConstants.h"
#import "RSNetworkResponse.h"
#import "RSDataResidencyManager.h"


@interface RSNetworkManager : NSObject {
    RSConfig* config;
    NSString* authToken;
    NSString* ctsAuthToken;
    NSString* anonymousIdToken;
    RSDataResidencyManager* dataResidencyManager;
    NSLock* networkLock;
}

extern NSString* const STATUS;
extern NSString* const RESPONSE;

- (instancetype)initWithConfig:(RSConfig *) config andAuthToken:(NSString *) authToken andAnonymousIdToken:(NSString *) anonymousIdToken andDataResidencyManager:(RSDataResidencyManager *) dataResidencyManager;
- (RSNetworkResponse *) sendNetworkRequest: (NSString*) payload toEndpoint:(ENDPOINT) endpoint withRequestMethod:(REQUEST_METHOD) method;
@end
