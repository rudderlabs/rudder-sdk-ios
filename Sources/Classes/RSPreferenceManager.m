//
//  RSPreferenceManager.m
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 27/01/20.
//

#import "RSPreferenceManager.h"
#import "RSLogger.h"
#import "RSServerConfigSource.h"
#import "RSUtils.h"

static RSPreferenceManager *instance;

@implementation RSPreferenceManager

NSString *const RSPrefsKey = @"rl_prefs";
NSString *const RSServerConfigKey = @"rl_server_config";
NSString *const RSServerLastUpdatedKey = @"rl_server_last_updated";
NSString *const RSTraitsKey = @"rl_traits";
NSString *const RSApplicationBuildKey = @"rl_application_build_key";
NSString *const RSApplicationVersionKey = @"rl_application_version_key";
NSString *const RSApplicationInfoKey = @"rl_application_info_key";
NSString *const RSExternalIdKey =  @"rl_external_id";
NSString *const RSAnonymousIdKey =  @"rl_anonymous_id";
NSString *const RSAuthToken = @"rl_auth_token";
NSString *const RSOptStatus = @"rl_opt_status";
NSString *const RSOptInTimeKey = @"rl_opt_in_time";
NSString *const RSOptOutTimeKey = @"rl_opt_out_time";
NSString *const RSSessionIdKey = @"rl_session_id";
NSString *const RSLastEventTimeStamp = @"rl_last_event_time_stamp";
NSString *const RSSessionAutoTrackStatus = @"rl_session_auto_track_status";
NSString *const RSEventDeletionStatus = @"rl_event_deletion_status";

+ (instancetype)getInstance {
    if (instance == nil) {
        instance = [[RSPreferenceManager alloc] init];
    }
    return instance;
}

- (void)updateLastUpdatedTime:(long)updatedTime {
    [[NSUserDefaults standardUserDefaults] setValue:[[NSNumber alloc] initWithLong:updatedTime] forKey:RSServerLastUpdatedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (long)getLastUpdatedTime {
    NSNumber *updatedTime = [[NSUserDefaults standardUserDefaults] valueForKey:RSServerLastUpdatedKey];
    if(updatedTime == nil) {
        return -1;
    } else {
        return [updatedTime longValue];
    }
}

- (void)saveConfigJson:(NSString *)configJson {
    [[NSUserDefaults standardUserDefaults] setValue:configJson forKey:RSServerConfigKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getConfigJson {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RSServerConfigKey];
}

- (void)saveTraits:(NSString *)traits {
    [[NSUserDefaults standardUserDefaults] setValue:traits forKey:RSTraitsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getTraits {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RSTraitsKey];
}

- (void)clearTraits {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:RSTraitsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString* __nullable) getBuildNumber {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RSApplicationBuildKey];
}

// saving the version number to the NSUserDefaults
- (void)saveBuildVersionCode:(NSString *)versionCode {
    [[NSUserDefaults standardUserDefaults] setValue:versionCode forKey:RSApplicationInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getBuildVersionCode {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RSApplicationInfoKey];
}

- (void) deleteBuildVersionCode {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:RSApplicationInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// saving the build number  to the NSUserDefaults
- (void) saveBuildNumber: (NSString* __nonnull) buildNumber {
    [[NSUserDefaults standardUserDefaults] setValue:buildNumber forKey:RSApplicationBuildKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// saving the version number to the NSUserDefaults
- (NSString* __nullable) getVersionNumber {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RSApplicationVersionKey];
}

- (void) saveVersionNumber: (NSString* __nonnull) versionNumber {
    [[NSUserDefaults standardUserDefaults] setValue:versionNumber forKey:RSApplicationVersionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getExternalIds {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RSExternalIdKey];
}

- (void)saveExternalIds:(NSString *)externalIdsJson {
    [[NSUserDefaults standardUserDefaults] setValue:externalIdsJson forKey:RSExternalIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearExternalIds {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:RSExternalIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getAnonymousId {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RSAnonymousIdKey];
}

- (void)saveAnonymousId:(NSString *)anonymousId {
    [[NSUserDefaults standardUserDefaults] setValue:anonymousId forKey:RSAnonymousIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)clearAnonymousId {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:RSAnonymousIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) clearAnonymousIdFromTraits {
    NSString* traitsStr = [self getTraits];
    NSError *error;
    NSMutableDictionary* traitsDict = [NSJSONSerialization JSONObjectWithData:[traitsStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(error == nil && traitsDict != nil) {
        [traitsDict removeObjectForKey:@"anonymousId"];
        NSString* finalTraitsStr = [RSUtils getStringFromDict:traitsDict];
        [self saveTraits:finalTraitsStr];
    }
}

- (void) clearCurrentAnonymousIdValue {
    [self clearAnonymousId];
    [self clearAnonymousIdFromTraits];
}

- (void) refreshAnonymousId {
    [self clearAnonymousId];
    [self saveAnonymousId:[RSUtils getUniqueId]];
}

- (NSString* __nullable) getAuthToken {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RSAuthToken];
}

- (void) saveAuthToken: (NSString* __nonnull) authToken {
    [[NSUserDefaults standardUserDefaults] setValue:authToken forKey:RSAuthToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) clearAuthToken {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:RSAuthToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)getOptStatus {
    return [[NSUserDefaults standardUserDefaults] boolForKey:RSOptStatus];
}

- (void)saveOptStatus:(BOOL) optStatus {
    [[NSUserDefaults standardUserDefaults] setBool:optStatus forKey:RSOptStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateOptInTime:(long)updatedTime {
    [[NSUserDefaults standardUserDefaults] setValue:[[NSNumber alloc] initWithLong:updatedTime] forKey:RSOptInTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (long)getOptInTime {
    NSNumber *updatedTime = [[NSUserDefaults standardUserDefaults] valueForKey:RSOptInTimeKey];
    if(updatedTime == nil) {
        return -1;
    } else {
        return [updatedTime longValue];
    }
}

- (void)updateOptOutTime:(long)updatedTime {
    [[NSUserDefaults standardUserDefaults] setValue:[[NSNumber alloc] initWithLong:updatedTime] forKey:RSOptOutTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (long)getOptOutTime {
    NSNumber *updatedTime = [[NSUserDefaults standardUserDefaults] valueForKey:RSOptOutTimeKey];
    if(updatedTime == nil) {
        return -1;
    } else {
        return [updatedTime longValue];
    }
}

- (void) performMigration {
    NSString* versionNumber = [self getBuildVersionCode];
    if(versionNumber != nil) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSPreferenceManager: performMigration: buildNumber stored in %@ key, migrating it to %@", RSApplicationInfoKey, RSApplicationBuildKey]];
        [self deleteBuildVersionCode];
        [self saveVersionNumber:versionNumber];
    }
}

- (void) saveSessionId: (NSNumber *) sessionId {
    [[NSUserDefaults standardUserDefaults] setValue:sessionId forKey:RSSessionIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber * __nullable) getSessionId {
    NSNumber* sessionId =  [[NSUserDefaults standardUserDefaults] valueForKey:RSSessionIdKey];
    if(sessionId == nil) {
        return nil;
    }
    return sessionId;
}

- (void) clearSessionId {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:RSSessionIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) saveLastEventTimeStamp:(NSNumber *) lastEventTimeStamp {
    [[NSUserDefaults standardUserDefaults] setValue:lastEventTimeStamp forKey:RSLastEventTimeStamp];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSNumber * __nullable) getLastEventTimeStamp {
    NSNumber *lastEventTimeStamp = [[NSUserDefaults standardUserDefaults] valueForKey:RSLastEventTimeStamp];
    if(lastEventTimeStamp == nil) {
        return nil;
    }
    return lastEventTimeStamp;
}

- (void) clearLastEventTimeStamp {
    [[NSUserDefaults standardUserDefaults] setValue:nil forKey:RSLastEventTimeStamp];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) saveAutoTrackingStatus: (BOOL) autoTrackingStatus {
    [[NSUserDefaults standardUserDefaults] setBool:autoTrackingStatus forKey:RSSessionAutoTrackStatus];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) getAutoTrackingStatus {
    return [[NSUserDefaults standardUserDefaults] boolForKey:RSSessionAutoTrackStatus];
}

- (BOOL)isErrorsCollectionEnabled {
    RSServerConfigSource *serverSourceConfig = [self getServerSourceConfig];
    if (serverSourceConfig != nil) {
        return serverSourceConfig.isErrorsCollectionEnabled;
    }
    return NO;
}

- (BOOL)isMetricsCollectionEnabled {
    RSServerConfigSource *serverSourceConfig = [self getServerSourceConfig];
    if (serverSourceConfig != nil) {
        return serverSourceConfig.isMetricsCollectionEnabled;
    }
    return NO;
}

- (RSServerConfigSource * __nullable)getServerSourceConfig {
    NSString* configStr = [self getConfigJson];
    if (configStr == nil) {
        return nil;
    }
    NSError *error;
    NSDictionary *configDict = [NSJSONSerialization JSONObjectWithData:[configStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (error == nil && configDict != nil) {
        RSServerConfigSource *config = [[RSServerConfigSource alloc] initWithConfigDict:configDict];
        return config;
    }
    return nil;
}

@end
