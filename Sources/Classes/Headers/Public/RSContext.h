//
//  RSContext.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RSConfig.h"
#import "RSApp.h"
#import "RSLibraryInfo.h"
#import "RSOSInfo.h"
#import "RSScreenInfo.h"
#import "RSDeviceInfo.h"
#import "RSNetwork.h"
#import "RSTraits.h"
#import "RSPreferenceManager.h"
#import "RSUserSession.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSContext : NSObject <NSCopying> {
    RSPreferenceManager *preferenceManager;
    NSDictionary<NSString *, NSArray<NSString *> *> * _Nullable consentManagement;
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
@property (nonatomic, readwrite) NSNumber * _Nullable sessionId;
@property (nonatomic, readwrite) BOOL sessionStart;
@property (nonatomic, readwrite) NSMutableArray<NSMutableDictionary<NSString*, NSObject*>*>* externalIds;

- (instancetype) initWithConfig:(RSConfig *) config;
- (instancetype) initWithDict:(NSDictionary*) dict;
+ (dispatch_queue_t) getQueue;
- (NSDictionary<NSString* , NSObject *>*) dict;
- (void) resetTraits;
- (void) updateTraits: (RSTraits* _Nullable) traits;
- (void)persistTraitsOnQueue;
- (void) updateTraitsDict: (NSMutableDictionary<NSString*, NSObject*>*) traitsDict;
- (void) updateTraitsAnonymousId;
- (void) putDeviceToken: (NSString*) deviceToken;
- (void) putAdvertisementId: (NSString *_Nonnull) idfa;
- (void) putAppTrackingConsent: (int) att;
- (void) updateExternalIds: (NSMutableArray* __nullable) externalIds;
- (void) resetExternalIdsOnQueue;
- (void) persistExternalIds;
- (NSArray<NSDictionary<NSString*, NSObject*>*>* __nullable)getExternalIds;
- (void) setSessionData:(RSUserSession *) userSession;
- (void)setConsentData:(NSArray <NSString *> *)deniedConsentIds;

@end

NS_ASSUME_NONNULL_END
