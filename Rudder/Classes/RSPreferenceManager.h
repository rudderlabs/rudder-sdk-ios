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
extern NSString *const RSAnonymousId;
extern NSString *const RSUserId;

+ (instancetype) getInstance;

- (void) updateLastUpdatedTime: (long) updatedTime;
- (long) getLastUpdatedTime;

- (void) saveConfigJson: (NSString* __nonnull) configJson;
- (NSString* __nullable) getConfigJson;

- (void) saveTraits: (NSString* __nonnull) traits;
- (NSString* __nonnull) getTraits;

- (NSString* __nullable) getBuildVersionCode;
- (void) saveBuildVersionCode: (NSString* __nonnull) versionCode;

- (void) saveAnonymousId: (NSString* __nonnull) anonymousId;
- (NSString* __nonnull) getAnonymousId;

- (void) setUserId: (NSString* __nonnull) userId;
- (NSString* __nonnull) getUserId;

@end

NS_ASSUME_NONNULL_END
