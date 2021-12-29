//
//  RSPreferenceManager.m
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 27/01/20.
//

#import "RSPreferenceManager.h"
#if TARGET_OS_WATCH
#import <WatchKit/WKInterfaceDevice.h>
#endif

static RSPreferenceManager *instance;

@implementation RSPreferenceManager

NSString *const RSPrefsKey = @"rl_prefs";
NSString *const RSServerConfigKey = @"rl_server_config";
NSString *const RSServerLastUpdatedKey = @"rl_server_last_updated";
NSString *const RSTraitsKey = @"rl_traits";
NSString *const RSApplicationInfoKey = @"rl_application_info_key";
NSString *const RSExternalIdKey =  @"rl_external_id";
NSString *const RSAnonymousIdKey =  @"rl_anonymous_id";
NSString *const RSOptStatus = @"rl_opt_status";
NSString *const RSOptInTimeKey = @"rl_opt_in_time";
NSString *const RSOptOutTimeKey = @"rl_opt_out_time";

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

- (void)saveBuildVersionCode:(NSString *)versionCode {
    [[NSUserDefaults standardUserDefaults] setValue:versionCode forKey:RSApplicationInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getBuildVersionCode {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RSApplicationInfoKey];
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
    NSString *anonymousId = [[NSUserDefaults standardUserDefaults] valueForKey:RSAnonymousIdKey];
    if (anonymousId == nil) {
#if !TARGET_OS_WATCH
        anonymousId = [[[[UIDevice currentDevice] identifierForVendor] UUIDString]lowercaseString];
#else
        anonymousId = [[[[WKInterfaceDevice currentDevice] identifierForVendor]UUIDString] lowercaseString];
#endif
    }

    
    [self saveAnonymousId:anonymousId];
    
    return anonymousId;
}

- (void)saveAnonymousId:(NSString *)anonymousId {
    [[NSUserDefaults standardUserDefaults] setValue:anonymousId forKey:RSAnonymousIdKey];
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

@end
