//
//  RSContext.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSContext.h"
#import "RSUtils.h"
#import "RSLogger.h"

static WKWebView *webView;

@implementation RSContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        self->preferenceManager = [RSPreferenceManager getInstance];
        
        _app = [[RSApp alloc] init];
        _device = [[RSDeviceInfo alloc] init];
        _library = [[RSLibraryInfo alloc] init];
        _os = [[RSOSInfo alloc] init];
        _screen = [[RSScreenInfo alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            webView = [[WKWebView alloc] initWithFrame:CGRectZero];
            [webView loadHTMLString:@"<html></html>" baseURL:nil];

            [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id __nullable userAgent, NSError * __nullable error) {
                self->_userAgent = userAgent;
            }];
        });
        _locale = [RSUtils getLocale];
        _network = [[RSNetwork alloc] init];
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
    RSTraits* traits = [[RSTraits alloc] init];
    traits.anonymousId = _device.identifier;
    _traits = [[traits dict]  mutableCopy];
    
    [self persistTraits];
}

- (void)updateTraits:(RSTraits *)traits {
    if(traits == nil) {
        traits = [[RSTraits alloc] init];
        traits.anonymousId = _device.identifier;
    }
    
//    _traits = [[traits dict] mutableCopy];
    
    [_traits setValuesForKeysWithDictionary:[traits dict]];
}

-(void) persistTraits {
    NSData *traitsJsonData = [NSJSONSerialization dataWithJSONObject:[RSUtils serializeDict:_traits] options:0 error:nil];
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

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    [tempDict setObject:[_app dict] forKey:@"app"];
    [tempDict setObject:[RSUtils serializeDict:_traits] forKey:@"traits"];
    [tempDict setObject:[_library dict] forKey:@"library"];
    [tempDict setObject:[_os dict] forKey:@"os"];
    [tempDict setObject:[_screen dict] forKey:@"screen"];
    [tempDict setObject:_userAgent ?: @"unknown" forKey:@"userAgent"];
    [tempDict setObject:_locale forKey:@"locale"];
    [tempDict setObject:[_device dict] forKey:@"device"];
    [tempDict setObject:[_network dict] forKey:@"network"];
    [tempDict setObject:_timezone forKey:@"timezone"];
    
    return [tempDict copy];
}

@end
