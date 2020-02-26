 //
//  RudderPreferenceManager.h
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 27/01/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RudderPreferenceManager : NSObject

extern NSString *const RudderPrefsKey;
extern NSString *const RudderServerConfigKey;
extern NSString *const RudderServerLastUpdatedKey;
extern NSString *const RudderTraitsKey;
extern NSString *const RudderApplicationInfoKey;

+ (instancetype) getInstance;

- (void) updateLastUpdatedTime: (long) updatedTime;
- (long) getLastUpdatedTime;

- (void) saveConfigJson: (NSString* __nonnull) configJson;
- (NSString* __nullable) getConfigJson;

- (void) saveTraits: (NSString* __nonnull) traits;
- (NSString* __nonnull) getTraits;

- (NSString* __nullable) getBuildVersionCode;
- (void) saveBuildVersionCode: (NSString* __nonnull) versionCode;

@end

NS_ASSUME_NONNULL_END
