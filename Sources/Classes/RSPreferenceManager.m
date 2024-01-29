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
static NSUserDefaults* userDefaults;

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
NSString *const RSLastActiveTimestamp = @"rl_last_event_time_stamp";
NSString *const RSSessionAutoTrackStatus = @"rl_session_auto_track_status";
NSString *const RSEventDeletionStatus = @"rl_event_deletion_status";
NSString *const suiteName = @"rudderstack";

+ (instancetype)getInstance {
    if (instance == nil) {
        instance = [[RSPreferenceManager alloc] init];
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName: suiteName];
    }
    return instance;
}

- (void)updateLastUpdatedTime:(long)updatedTime {
    [userDefaults setValue:[[NSNumber alloc] initWithLong:updatedTime] forKey:RSServerLastUpdatedKey];
    [userDefaults synchronize];
}

- (long)getLastUpdatedTime {
    NSNumber *updatedTime = [userDefaults valueForKey:RSServerLastUpdatedKey];
    if(updatedTime == nil) {
        return -1;
    } else {
        return [updatedTime longValue];
    }
}

- (void)saveConfigJson:(NSString *)configJson {
    [userDefaults setValue:configJson forKey:RSServerConfigKey];
    [userDefaults synchronize];
}

- (NSString *)getConfigJson {
    return [userDefaults valueForKey:RSServerConfigKey];
}

- (void)saveTraits:(NSString *)traits {
    [userDefaults setValue:traits forKey:RSTraitsKey];
    [userDefaults synchronize];
}

- (NSString *)getTraits {
    return [userDefaults valueForKey:RSTraitsKey];
}

- (void)clearTraits {
    [userDefaults setValue:nil forKey:RSTraitsKey];
    [userDefaults synchronize];
}

- (NSString* __nullable) getBuildNumber {
    return [userDefaults valueForKey:RSApplicationBuildKey];
}

// saving the version number to the NSUserDefaults
- (void)saveBuildVersionCode:(NSString *)versionCode {
    [userDefaults setValue:versionCode forKey:RSApplicationInfoKey];
    [userDefaults synchronize];
}

- (NSString *)getBuildVersionCode {
    return [userDefaults valueForKey:RSApplicationInfoKey];
}

- (void) deleteBuildVersionCode {
    [userDefaults removeObjectForKey:RSApplicationInfoKey];
    [userDefaults synchronize];
}

// saving the build number  to the NSUserDefaults
- (void) saveBuildNumber: (NSString* __nonnull) buildNumber {
    [userDefaults setValue:buildNumber forKey:RSApplicationBuildKey];
    [userDefaults synchronize];
}

// saving the version number to the NSUserDefaults
- (NSString* __nullable) getVersionNumber {
    return [userDefaults valueForKey:RSApplicationVersionKey];
}

- (void) saveVersionNumber: (NSString* __nonnull) versionNumber {
    [userDefaults setValue:versionNumber forKey:RSApplicationVersionKey];
    [userDefaults synchronize];
}

- (NSString *)getExternalIds {
    return [userDefaults valueForKey:RSExternalIdKey];
}

- (void)saveExternalIds:(NSString *)externalIdsJson {
    [userDefaults setValue:externalIdsJson forKey:RSExternalIdKey];
    [userDefaults synchronize];
}

- (void)clearExternalIds {
    [userDefaults setValue:nil forKey:RSExternalIdKey];
    [userDefaults synchronize];
}

- (NSString *)getAnonymousId {
    return [userDefaults valueForKey:RSAnonymousIdKey];
}

- (void)saveAnonymousId:(NSString *)anonymousId {
    [userDefaults setValue:anonymousId forKey:RSAnonymousIdKey];
    [userDefaults synchronize];
}

- (void)clearAnonymousId {
    [userDefaults setValue:nil forKey:RSAnonymousIdKey];
    [userDefaults synchronize];
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
    return [userDefaults valueForKey:RSAuthToken];
}

- (void) saveAuthToken: (NSString* __nonnull) authToken {
    [userDefaults setValue:authToken forKey:RSAuthToken];
    [userDefaults synchronize];
}

- (void) clearAuthToken {
    [userDefaults setValue:nil forKey:RSAuthToken];
    [userDefaults synchronize];
}

- (BOOL)getOptStatus {
    return [userDefaults boolForKey:RSOptStatus];
}

- (void)saveOptStatus:(BOOL) optStatus {
    [userDefaults setBool:optStatus forKey:RSOptStatus];
    [userDefaults synchronize];
}

- (void)updateOptInTime:(long)updatedTime {
    [userDefaults setValue:[[NSNumber alloc] initWithLong:updatedTime] forKey:RSOptInTimeKey];
    [userDefaults synchronize];
}

- (long)getOptInTime {
    NSNumber *updatedTime = [userDefaults valueForKey:RSOptInTimeKey];
    if(updatedTime == nil) {
        return -1;
    } else {
        return [updatedTime longValue];
    }
}

- (void)updateOptOutTime:(long)updatedTime {
    [userDefaults setValue:[[NSNumber alloc] initWithLong:updatedTime] forKey:RSOptOutTimeKey];
    [userDefaults synchronize];
}

- (long)getOptOutTime {
    NSNumber *updatedTime = [userDefaults valueForKey:RSOptOutTimeKey];
    if(updatedTime == nil) {
        return -1;
    } else {
        return [updatedTime longValue];
    }
}

- (void) saveSessionId: (NSNumber *) sessionId {
    [userDefaults setValue:sessionId forKey:RSSessionIdKey];
    [userDefaults synchronize];
}

- (NSNumber * __nullable) getSessionId {
    NSNumber* sessionId =  [userDefaults valueForKey:RSSessionIdKey];
    if(sessionId == nil) {
        return nil;
    }
    return sessionId;
}

- (void) clearSessionId {
    [userDefaults setValue:nil forKey:RSSessionIdKey];
    [userDefaults synchronize];
}

- (void) saveLastActiveTimestamp:(NSNumber *) lastActiveTimestamp {
    [userDefaults setValue:lastActiveTimestamp forKey:RSLastActiveTimestamp];
    [userDefaults synchronize];
}

- (NSNumber * __nullable) getLastActiveTimestamp {
    NSNumber *lastActiveTimestamp = [userDefaults valueForKey:RSLastActiveTimestamp];
    if(lastActiveTimestamp == nil) {
        return nil;
    }
    return lastActiveTimestamp;
}

- (void) clearLastActiveTimestamp {
    [userDefaults setValue:nil forKey:RSLastActiveTimestamp];
    [userDefaults synchronize];
}

- (void) saveAutoTrackingStatus: (BOOL) autoTrackingStatus {
    [userDefaults setBool:autoTrackingStatus forKey:RSSessionAutoTrackStatus];
    [userDefaults synchronize];
}

- (BOOL) getAutoTrackingStatus {
    return [userDefaults boolForKey:RSSessionAutoTrackStatus];
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

- (void) performMigration {
    
    // migration from standard defaults to defaults created with suiteName rudderstack
    BOOL migrated = [userDefaults boolForKey:@"defaultsMigrated"];
    // Perform the migration only if it hasn't been done before
    if (!migrated) {
        NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *keysToMigrate = @[RSPrefsKey, RSServerConfigKey, RSServerLastUpdatedKey, RSTraitsKey, RSApplicationBuildKey, RSApplicationVersionKey, RSApplicationInfoKey, RSExternalIdKey, RSAnonymousIdKey, RSAuthToken, RSOptStatus, RSOptInTimeKey, RSOptOutTimeKey, RSSessionIdKey, RSLastActiveTimestamp, RSSessionAutoTrackStatus, RSEventDeletionStatus];
        
        for (NSString *key in keysToMigrate) {
            id valueToMigrate = [standardDefaults objectForKey:key];
            if (valueToMigrate != nil) {
                [userDefaults setObject:valueToMigrate forKey:key];
            }
        }
        
        // Set flag to indicate that migration has been completed
        [userDefaults setBool:YES forKey:@"DefaultsMigrated"];
        [userDefaults synchronize];
    }
    
    // migration of buildVersionCode to versionNumber
    NSString* versionNumber = [self getBuildVersionCode];
    if(versionNumber != nil) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSPreferenceManager: performMigration: buildNumber stored in %@ key, migrating it to %@", RSApplicationInfoKey, RSApplicationBuildKey]];
        [self deleteBuildVersionCode];
        [self saveVersionNumber:versionNumber];
    }
}

@end
