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
        _traits = [[NSMutableDictionary alloc] init];
        _library = [[RudderLibraryInfo alloc] init];
        _os = [[RudderOSInfo alloc] init];
        _screen = [[RudderScreenInfo alloc] init];
        _userAgent = @"ios";
        _locale = [Utils getLocale];
        _device = [[RudderDeviceInfo alloc] init];
        _network = [[RudderNetwork alloc] init];
        _timezone = [[NSTimeZone localTimeZone] name];
        
        [_traits setValue:_device.identifier forKey:@"anonymousId"];
    }
    return self;
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
