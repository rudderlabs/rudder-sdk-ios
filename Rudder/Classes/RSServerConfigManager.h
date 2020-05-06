//
//  RSServerConfigManager.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSServerConfigSource.h"
#import "RSConfig.h"
#import "RSPreferenceManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSServerConfigManager : NSObject {
    NSString *_writeKey;
    RSServerConfigSource *_serverConfig;
    RSConfig *_rudderConfig;
    RSPreferenceManager *_preferenceManager;
}

+ (instancetype) getInstance: (NSString*) writeKey rudderConfig:(RSConfig*) rudderConfig;
- (BOOL) _isServerConfigOutDated;
- (RSServerConfigSource* _Nullable) _retrieveConfig;
- (void) _downloadConfig;
- (RSServerConfigSource*) getConfig;
- (RSServerConfigSource*) _parseConfig: (NSString*) configStr;
- (NSString*) _networkRequest;

@end

NS_ASSUME_NONNULL_END
