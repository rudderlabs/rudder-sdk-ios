//
//  RSPreferenceManager.h
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 27/01/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSPreferenceManager : NSObject

extern NSString *const RSPrefsKey;
extern NSString *const RSServerConfigKey;
extern NSString *const RSServerLastUpdatedKey;
extern NSString *const RSTraitsKey;
extern NSString *const RSApplicationInfoKey;
extern NSString *const RSExternalIdKey;
extern NSString *const RSOptStatus;
extern NSString *const RSOptInTimeKey;
extern NSString *const RSOptOutTimeKey;
extern NSString *const RSSessionIdKey;
extern NSString *const RSLastEventTimeStamp;
extern NSString *const RSSessionAutoTrackStatus;

+ (instancetype) getInstance;

- (void) updateLastUpdatedTime: (long) updatedTime;
- (long) getLastUpdatedTime;

- (void) saveConfigJson: (NSString* __nonnull) configJson;
- (NSString* __nullable) getConfigJson;

- (void) saveTraits: (NSString* __nonnull) traits;
- (NSString* __nonnull) getTraits;
- (void) clearTraits;

- (void) saveBuildVersionCode:(NSString* __nonnull)versionCode;
- (NSString* __nullable) getBuildVersionCode; 
- (void) deleteBuildVersionCode;

- (void) performMigration;

- (NSString* __nullable) getBuildNumber;
- (void) saveBuildNumber: (NSString* __nonnull) buildNumber;

- (NSString* __nullable) getVersionNumber;
- (void) saveVersionNumber: (NSString* __nonnull) versionNumber;

- (NSString* __nullable) getExternalIds;
- (void) saveExternalIds: (NSString* __nonnull) externalIdsJson;
- (void) clearExternalIds;

- (NSString* __nullable) getAnonymousId;
- (void) saveAnonymousId: (NSString* __nullable) anonymousId;
- (void) clearAnonymousId;
- (void) clearCurrentAnonymousIdValue;
- (void) refreshAnonymousId;

- (NSString* __nullable) getAuthToken;
- (void) saveAuthToken: (NSString* __nonnull) authToken;
- (void) clearAuthToken;

- (BOOL) getOptStatus;
- (void) saveOptStatus: (BOOL) optStatus;
- (void) updateOptInTime: (long) updatedTime;
- (long) getOptInTime;
- (void) updateOptOutTime: (long) updatedTime;
- (long) getOptOutTime;

- (void) saveSessionId: (NSNumber *) sessionId;
- (NSNumber * __nullable) getSessionId;
- (void) clearSessionId;

- (void) saveLastEventTimeStamp: (NSNumber *) lastEventTimeStamp;
- (NSNumber * __nullable) getLastEventTimeStamp;
- (void) clearLastEventTimeStamp;

- (void) saveAutoTrackingStatus: (BOOL) autoTrackingStatus;
- (BOOL) getAutoTrackingStatus;

@property (nonatomic, readwrite) BOOL isMetricsCollectionEnabled;
@property (nonatomic, readwrite) BOOL isErrorsCollectionEnabled;

@end

NS_ASSUME_NONNULL_END
