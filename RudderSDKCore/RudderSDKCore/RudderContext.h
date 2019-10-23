//
//  RudderContext.h
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RudderApp.h"
#import "RudderLibraryInfo.h"
#import "RudderOSInfo.h"
#import "RudderScreenInfo.h"
#import "RudderDeviceInfo.h"
#import "RudderNetwork.h"
#import "RudderTraits.h"

NS_ASSUME_NONNULL_BEGIN

@interface RudderContext : NSObject

@property (nonatomic, readwrite) RudderApp* app;
@property (nonatomic, readwrite) RudderTraits *traits;
@property (nonatomic, readwrite) RudderLibraryInfo* library;
@property (nonatomic, readwrite) RudderOSInfo* os;
@property (nonatomic, readwrite) RudderScreenInfo* screen;
@property (nonatomic, readwrite) NSString* userAgent;
@property (nonatomic, readwrite) NSString* locale;
@property (nonatomic, readwrite) RudderDeviceInfo* device;
@property (nonatomic, readwrite) RudderNetwork* network;
@property (nonatomic, readwrite) NSString* timezone;

- (NSDictionary<NSString* , NSObject *>*) dict;
- (void) updateTraits: (RudderTraits*) traits;

@end

NS_ASSUME_NONNULL_END
