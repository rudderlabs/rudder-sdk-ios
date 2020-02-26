//
//  RudderServerConfigManager.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderServerConfigSource.h"
#import "RudderConfig.h"
#import "RudderPreferenceManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface RudderServerConfigManager : NSObject {
    NSString *_writeKey;
    RudderServerConfigSource *_serverConfig;
    RudderConfig *_rudderConfig;
    RudderPreferenceManager *_preferenceManager;
}

+ (instancetype) getInstance: (NSString*) writeKey rudderConfig:(RudderConfig*) rudderConfig;
- (BOOL) _isServerConfigOutDated;
- (RudderServerConfigSource* _Nullable) _retrieveConfig;
- (void) _downloadConfig;
- (RudderServerConfigSource*) getConfig;
- (RudderServerConfigSource*) _parseConfig: (NSString*) configStr;
- (NSString*) _networkRequest;

@end

NS_ASSUME_NONNULL_END
