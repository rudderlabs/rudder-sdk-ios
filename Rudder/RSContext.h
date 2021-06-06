//
//  RSContext.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "RSApp.h"
#import "RSLibraryInfo.h"
#import "RSOSInfo.h"
#import "RSScreenInfo.h"
#import "RSDeviceInfo.h"
#import "RSNetwork.h"
#import "RSTraits.h"
#import "RSPreferenceManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSContext : NSObject <NSCopying> {
    RSPreferenceManager *preferenceManager;
}

extern int const RSATTNotDetermined;
extern int const RSATTRestricted;
extern int const RSATTDenied;
extern int const RSATTAuthorize;

@property (nonatomic, readwrite) RSApp* app;
@property (nonatomic, readwrite) NSMutableDictionary<NSString*, NSObject*>* traits;
@property (nonatomic, readwrite) RSLibraryInfo* library;
@property (nonatomic, readwrite) RSOSInfo* os;
@property (nonatomic, readwrite) RSScreenInfo* screen;
@property (nonatomic, readwrite) NSString* userAgent;
@property (nonatomic, readwrite) NSString* locale;
@property (nonatomic, readwrite) RSDeviceInfo* device;
@property (nonatomic, readwrite) RSNetwork* network;
@property (nonatomic, readwrite) NSString* timezone;
@property (nonatomic, readwrite) NSMutableArray* externalIds;

- (NSDictionary<NSString* , NSObject *>*) dict;
- (void) updateTraits: (RSTraits* _Nullable) traits;
- (void) persistTraits;
- (void) updateTraitsDict: (NSMutableDictionary<NSString*, NSObject*>*) traitsDict;
- (void) putDeviceToken: (NSString*) deviceToken;
- (void) putAdvertisementId: (NSString*) idfa;
- (void) putAppTrackingConsent: (int) att;
- (void) updateExternalIds: (NSMutableArray* __nullable) externalIds;

@end

NS_ASSUME_NONNULL_END
