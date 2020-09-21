//
//  RSPreferenceManager.m
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 27/01/20.
//

#import "RSPreferenceManager.h"

static RSPreferenceManager *instance;

@implementation RSPreferenceManager

NSString *const RSPrefsKey = @"rl_prefs";
NSString *const RSServerConfigKey = @"rl_server_config";
NSString *const RSServerLastUpdatedKey = @"rl_server_last_updated";
NSString *const RSTraitsKey = @"rl_traits";
NSString *const RSApplicationInfoKey = @"rl_application_info_key";
NSString *const RSExternalIdKey =  @"rl_external_id";

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

@end
