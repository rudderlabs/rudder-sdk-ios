//
//  RudderContext.m
//  RudderSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 Rudderlabs. All rights reserved.
//

#import "RudderContext.h"
#import "Utils.h"
#import "RudderLogger.h"

static WKWebView *webView;

@implementation RudderContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->preferenceManager = [RudderPreferenceManager getInstance];
        
        _app = [[RudderApp alloc] init];
        _device = [[RudderDeviceInfo alloc] init];
        _library = [[RudderLibraryInfo alloc] init];
        _os = [[RudderOSInfo alloc] init];
        _screen = [[RudderScreenInfo alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            webView = [[WKWebView alloc] initWithFrame:CGRectZero];
            [webView loadHTMLString:@"<html></html>" baseURL:nil];

            [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id __nullable userAgent, NSError * __nullable error) {
                self->_userAgent = userAgent;
                NSLog(@"++++++++++++++++++++++++++++ : %@", userAgent);
            }];
        });
        _locale = [Utils getLocale];
        _network = [[RudderNetwork alloc] init];
        _timezone = [[NSTimeZone localTimeZone] name];
        
        NSString *traitsJson = [preferenceManager getTraits];
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
    
    [preferenceManager saveTraits:traitsString];
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

- (void)putDeviceToken:(NSString *)deviceToken {
    _device.token = deviceToken;
}

- (NSString*) getLocalUAString {
    return [[NSString alloc] initWithFormat:@"%@/%@ %@/%@ %@/%@",
            _app.name, _app.version,
            _device.model, _device.name,
            _os.name, _os.version
            ];
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:[_app dict] forKey:@"app"];
    [tempDict setObject:_traits forKey:@"traits"];
    [tempDict setObject:[_library dict] forKey:@"library"];
    [tempDict setObject:[_os dict] forKey:@"os"];
    [tempDict setObject:[_screen dict] forKey:@"screen"];
    [tempDict setObject:_userAgent ?: [self getLocalUAString] forKey:@"userAgent"];
    [tempDict setObject:_locale forKey:@"locale"];
    [tempDict setObject:[_device dict] forKey:@"device"];
    [tempDict setObject:[_network dict] forKey:@"network"];
    [tempDict setObject:_timezone forKey:@"timezone"];
    
    return [tempDict copy];
}

@end
