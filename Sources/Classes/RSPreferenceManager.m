//
//  RSPreferenceManager.m
//  Rudder
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
NSString *const RSLastActiveTimestamp = @"rl_last_event_time_stamp";
NSString *const RSSessionAutoTrackStatus = @"rl_session_auto_track_status";
NSString *const RSEventDeletionStatus = @"rl_event_deletion_status";

+ (NSArray *) getPreferenceKeys {
    return @[RSPrefsKey, RSServerConfigKey, RSServerLastUpdatedKey, RSTraitsKey, RSApplicationBuildKey, RSApplicationVersionKey, RSApplicationInfoKey, RSExternalIdKey, RSAnonymousIdKey, RSAuthToken, RSOptStatus, RSOptInTimeKey, RSOptOutTimeKey, RSSessionIdKey, RSLastActiveTimestamp, RSSessionAutoTrackStatus, RSEventDeletionStatus];
}


+ (instancetype)getInstance {
    if (instance == nil) {
        instance = [[RSPreferenceManager alloc] init];
    }
    return instance;
}

- (void)writeObject:(id)object forKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setValue:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // writing the values to persistence layer as well
    [[RSDefaultsPersistence sharedInstance] writeObject:object forKey:key];
}

- (void)writeBool:(BOOL)flag forKey:(NSString *) key {
    NSNumber* flagAsNum = [[NSNumber alloc] initWithBool:flag];
    [self writeObject:flagAsNum forKey:key];
}

- (id)readObjectForKey:(NSString *) key {
    // try reading from standard defaults, if it is a miss then read from persistence layer
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(value != nil) {
        return value;
    }
    return [[RSDefaultsPersistence sharedInstance] readObjectForKey:key];
}

- (BOOL)readBoolForKey:(NSString *) key {
    id value = [self readObjectForKey:key];
    if(value == nil) {
        value = [[RSDefaultsPersistence sharedInstance] readObjectForKey:key];
    }
    NSNumber* valueAsNum = (NSNumber *) value;
    return [valueAsNum boolValue];
}

- (void)removeObjectForKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // deleting the values from persistence layer as well
    [[RSDefaultsPersistence sharedInstance] removeObjectForKey:key];
}

- (void)updateLastUpdatedTime:(long)updatedTime {
    [self writeObject:[[NSNumber alloc] initWithLong:updatedTime] forKey:RSServerLastUpdatedKey];
}

- (long)getLastUpdatedTime {
    NSNumber *updatedTime = [self readObjectForKey:RSServerLastUpdatedKey];
    if(updatedTime == nil) {
        return -1;
    } else {
        return [updatedTime longValue];
    }
}

- (void)saveConfigJson:(NSString *)configJson {
    [self writeObject:configJson forKey:RSServerConfigKey];
}

- (NSString *)getConfigJson {
    return [self readObjectForKey:RSServerConfigKey];
}

- (void)saveTraits:(NSString *)traits {
    [self writeObject:traits forKey:RSTraitsKey];
}

- (NSString *)getTraits {
    return [self readObjectForKey:RSTraitsKey];
}

- (void)clearTraits {
    [self removeObjectForKey:RSTraitsKey];
}

- (NSString* __nullable) getBuildNumber {
    return [self readObjectForKey:RSApplicationBuildKey];
}

// saving the version number to the NSUserDefaults
- (void)saveBuildVersionCode:(NSString *)versionCode {
    [self writeObject:versionCode forKey:RSApplicationInfoKey];
}

- (NSString *)getBuildVersionCode {
    return [self readObjectForKey:RSApplicationInfoKey];
}

- (void) deleteBuildVersionCode {
    [self removeObjectForKey:RSApplicationInfoKey];
}

// saving the build number  to the NSUserDefaults
- (void) saveBuildNumber: (NSString* __nonnull) buildNumber {
    [self writeObject:buildNumber forKey:RSApplicationBuildKey];
}

// saving the version number to the NSUserDefaults
- (NSString* __nullable) getVersionNumber {
    return [self readObjectForKey:RSApplicationVersionKey];
}

- (void) saveVersionNumber: (NSString* __nonnull) versionNumber {
    [self writeObject:versionNumber forKey:RSApplicationVersionKey];
}

- (NSString *)getExternalIds {
    return [self readObjectForKey:RSExternalIdKey];
}

- (void)saveExternalIds:(NSString *)externalIdsJson {
    [self writeObject:externalIdsJson forKey:RSExternalIdKey];
}

- (void)clearExternalIds {
    [self removeObjectForKey:RSExternalIdKey];
}

- (NSString *)getAnonymousId {
    return [self readObjectForKey:RSAnonymousIdKey];
}

- (void)saveAnonymousId:(NSString *)anonymousId {
    [self writeObject:anonymousId forKey:RSAnonymousIdKey];
}

- (void)clearAnonymousId {
    [self removeObjectForKey:RSAnonymousIdKey];
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
    return [self readObjectForKey:RSAuthToken];
}

- (void) saveAuthToken: (NSString* __nonnull) authToken {
    [self writeObject:authToken forKey:RSAuthToken];
}

- (void) clearAuthToken {
    [self removeObjectForKey:RSAuthToken];
}

- (BOOL)getOptStatus {
    return [self readBoolForKey:RSOptStatus];
}

- (void)saveOptStatus:(BOOL) optStatus {
    [self writeBool:optStatus forKey:RSOptStatus];
}

- (void)updateOptInTime:(long)updatedTime {
    [self writeObject:[[NSNumber alloc] initWithLong:updatedTime] forKey:RSOptInTimeKey];
}

- (long)getOptInTime {
    NSNumber *updatedTime = [self readObjectForKey:RSOptInTimeKey];
    if(updatedTime == nil) {
        return -1;
    } else {
        return [updatedTime longValue];
    }
}

- (void)updateOptOutTime:(long)updatedTime {
    [self writeObject:[[NSNumber alloc] initWithLong:updatedTime] forKey:RSOptOutTimeKey];
}

- (long)getOptOutTime {
    NSNumber *updatedTime = [self readObjectForKey:RSOptOutTimeKey];
    if(updatedTime == nil) {
        return -1;
    } else {
        return [updatedTime longValue];
    }
}

- (void) saveSessionId: (NSNumber *) sessionId {
    [self writeObject:sessionId forKey:RSSessionIdKey];
}

- (NSNumber * __nullable) getSessionId {
    return [self readObjectForKey:RSSessionIdKey];
}

- (void) clearSessionId {
    [self removeObjectForKey:RSSessionIdKey];
}

- (void) saveLastActiveTimestamp:(NSNumber *) lastActiveTimestamp {
    [self writeObject:lastActiveTimestamp forKey:RSLastActiveTimestamp];
}

- (NSNumber * __nullable) getLastActiveTimestamp {
    return [self readObjectForKey:RSLastActiveTimestamp];
}

- (void) clearLastActiveTimestamp {
    [self removeObjectForKey:RSLastActiveTimestamp];
}

- (void) saveAutoTrackingStatus: (BOOL) autoTrackingStatus {
    [self writeBool:autoTrackingStatus forKey:RSSessionAutoTrackStatus];
}

- (BOOL) getAutoTrackingStatus {
    return [self readBoolForKey:RSSessionAutoTrackStatus];
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
    // migration of buildVersionCode to versionNumber
    NSString* versionNumber = [self getBuildVersionCode];
    if(versionNumber != nil) {
        [RSLogger logDebug:[[NSString alloc] initWithFormat:@"RSPreferenceManager: performMigration: buildNumber stored in %@ key, migrating it to %@", RSApplicationInfoKey, RSApplicationBuildKey]];
        [self deleteBuildVersionCode];
        [self saveVersionNumber:versionNumber];
    }
}

- (void) restoreMissingKeysFromPersistence {
    // Check for missing keys and restore them from the persistent layer
    NSArray* preferenceKeys = [RSPreferenceManager getPreferenceKeys];
    for (NSString *key in preferenceKeys) {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) {
            id value = [[RSDefaultsPersistence sharedInstance] readObjectForKey:key];
            if (value != nil) {
                [self writeObject:value forKey:key];
            }
        }
    }
}

@end
