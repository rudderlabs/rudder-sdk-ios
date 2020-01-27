//
//  RudderPreferenceManager.m
//  Pods-DummyTestProject
//
//  Created by Arnab Pal on 27/01/20.
//

#import "RudderPreferenceManager.h"

static RudderPreferenceManager *instance;

@implementation RudderPreferenceManager

NSString *const RudderPrefsKey = @"rl_prefs";
NSString *const RudderServerConfigKey = @"rl_server_config";
NSString *const RudderServerLastUpdatedKey = @"rl_server_last_updated";
NSString *const RudderTraitsKey = @"rl_traits";
NSString *const RudderApplicationInfoKey = @"rl_application_info_key";

+ (instancetype)getInstance {
    if (instance == nil) {
        instance = [[RudderPreferenceManager alloc] init];
    }
    return instance;
}

- (void)updateLastUpdatedTime:(long)updatedTime {
    [[NSUserDefaults standardUserDefaults] setValue:[[NSNumber alloc] initWithLong:updatedTime] forKey:RudderServerLastUpdatedKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (long)getLastUpdatedTime {
    NSNumber *updatedTime = [[NSUserDefaults standardUserDefaults] valueForKey:RudderServerLastUpdatedKey];
    if(updatedTime == nil) {
        return -1;
    } else {
        return [updatedTime longValue];
    }
}

- (void)saveConfigJson:(NSString *)configJson {
    [[NSUserDefaults standardUserDefaults] setValue:configJson forKey:RudderServerConfigKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getConfigJson {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RudderServerConfigKey];
}

- (void)saveTraits:(NSString *)traits {
    [[NSUserDefaults standardUserDefaults] setValue:traits forKey:RudderTraitsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getTraits {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RudderTraitsKey];
}

- (void)saveBuildVersionCode:(NSString *)versionCode {
    [[NSUserDefaults standardUserDefaults] setValue:versionCode forKey:RudderApplicationInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getBuildVersionCode {
    return [[NSUserDefaults standardUserDefaults] valueForKey:RudderApplicationInfoKey];
}

@end
