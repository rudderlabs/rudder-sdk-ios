//
//  RudderContext.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderContext.h"
#import "Utils.h"

@implementation RudderContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        _app = [[RudderApp alloc] init];
        _device = [[RudderDeviceInfo alloc] init];
        _library = [[RudderLibraryInfo alloc] init];
        _os = [[RudderOSInfo alloc] init];
        _screen = [[RudderScreenInfo alloc] init];
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        _locale = [Utils getLocale];
        _network = [[RudderNetwork alloc] init];
        _timezone = [[NSTimeZone localTimeZone] name];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *traitsJson = [userDefaults objectForKey:@"rl_traits"];
        if (traitsJson == nil) {
            // no persisted traits, create new and persist
            [self createAndPersistTraits];
        } else {
            NSError *error;
            NSDictionary *traitsDict = [NSJSONSerialization JSONObjectWithData:[traitsJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
            if (error == nil) {
                _traits = [traitsDict mutableCopy];
            } else {
                // persisted traits persing error. initiate blank
                [self createAndPersistTraits];
            }
        }
    }
    return self;
}

- (void) createAndPersistTraits {
    RudderTraits* traits = [[RudderTraits alloc] init];
    traits.anonymousId = _device.identifier;
    _traits = [[traits dict]  mutableCopy];
    
    [self persistTraits];
}

- (void)updateTraits:(RudderTraits *)traits {
    if(traits == nil) {
        traits = [[RudderTraits alloc] init];
        traits.anonymousId = _device.identifier;
    }
    
    _traits = [[traits dict] mutableCopy];
}

-(void) persistTraits {
    NSData *traitsJsonData = [NSJSONSerialization dataWithJSONObject:_traits options:0 error:nil];
    NSString *traitsString = [[NSString alloc] initWithData:traitsJsonData encoding:NSUTF8StringEncoding];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:traitsString forKey:@"rl_traits"];
}

- (void)updateTraitsDict:(NSMutableDictionary<NSString *, NSObject *> *)traitsDict {
    if (traitsDict == nil) {
        traitsDict = [[NSMutableDictionary alloc] init];
    }
    NSObject *anonymousId = [traitsDict objectForKey:@"anonymousId"];
    if (anonymousId == nil) {
        [traitsDict setObject:_device.identifier forKey:@"anonymousId"];
    }
    _traits = traitsDict;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:[_app dict] forKey:@"app"];
    [tempDict setObject:_traits forKey:@"traits"];
    [tempDict setObject:[_library dict] forKey:@"library"];
    [tempDict setObject:[_os dict] forKey:@"os"];
    [tempDict setObject:[_screen dict] forKey:@"screen"];
    [tempDict setObject:_userAgent forKey:@"userAgent"];
    [tempDict setObject:_locale forKey:@"locale"];
    [tempDict setObject:[_device dict] forKey:@"device"];
    [tempDict setObject:[_network dict] forKey:@"network"];
    [tempDict setObject:_timezone forKey:@"timezone"];
    
    return [tempDict copy];
}

@end
