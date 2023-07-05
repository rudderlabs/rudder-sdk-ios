//
//  RSServerConfigManager.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSConfig.h"
#import "RSPreferenceManager.h"
#import "RSNetworkManager.h"
#import "RSServerConfigSource.h"


NS_ASSUME_NONNULL_BEGIN

@interface RSServerConfigManager : NSObject {
    NSString *writeKey;
    RSConfig *rudderConfig;
    RSPreferenceManager *preferenceManager;
    RSNetworkManager* networkManager;
}

- (instancetype)init: (NSString*) writeKey rudderConfig:(RSConfig*) rudderConfig andNetworkManager: (RSNetworkManager *) networkManager;
- (RSServerConfigSource*) getConfig;
- (NSDictionary<NSString*, NSString*>*) getDestinationsWithTransformationsEnabled;
- (NSArray<NSString*>*) getDestinationsAcceptingEventsOnTransformationError;
- (int) getError;
- (RSServerConfigSource *_Nullable)_parseConfig:(NSString *)configStr;

@end

NS_ASSUME_NONNULL_END
