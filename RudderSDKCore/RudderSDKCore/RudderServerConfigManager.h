//
//  RudderServerConfigManager.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderServerConfigSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface RudderServerConfigManager : NSObject {
    NSString *_writeKey;
    RudderServerConfigSource *_serverConfig;
}

+ (instancetype) getInstance: (NSString*) writeKey;
- (BOOL) _isServerConfigOutDated;
- (RudderServerConfigSource*) _retrieveConfig;
- (void) _downloadConfig;
- (RudderServerConfigSource*) getConfig;
- (RudderServerConfigSource*) _parseConfig: (NSString*) configStr;
- (NSString*) _networkRequest;

@end

NS_ASSUME_NONNULL_END
