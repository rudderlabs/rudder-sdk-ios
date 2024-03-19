//
//  RSDeviceInfo.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSDeviceInfo.h"
#import "RSContext.h"
#import <UIKit/UIKit.h>
#import "RSConstants.h"
#import <sys/sysctl.h>
#if TARGET_OS_WATCH
#import <WatchKit/WKInterfaceDevice.h>
#endif


@implementation RSDeviceInfo

- (instancetype) initWithConfig: (RSConfig *) config {
    self = [super init];
    if (self) {
#if !TARGET_OS_WATCH
        _identifier = config.collectDeviceId ? [[[[UIDevice currentDevice] identifierForVendor] UUIDString]lowercaseString] : nil;
        _name = [[UIDevice currentDevice] name];
        _type = [[UIDevice currentDevice] systemName];
#else
        _identifier = config.collectDeviceId ? [[[[WKInterfaceDevice currentDevice] identifierForVendor]UUIDString] lowercaseString] : nil;
        _name = [[WKInterfaceDevice currentDevice]name];
        _type = [[WKInterfaceDevice currentDevice]systemName];
#endif
        _model = [self getDeviceModel];
        _manufacturer = @"Apple";
        _attTrackingStatus = RSATTNotDetermined;
        _advertisingId = [[RSPreferenceManager getInstance] getAdvertisingId];
        if(_advertisingId != nil) {
            _adTrackingEnabled = YES;
        }
    }
    return self;
}

- (instancetype) initWithDict:(NSDictionary*) dict {
    self = [super init];
    if(self) {
        _identifier = dict[@"id"];
        _manufacturer = dict[@"manufacturer"];
        _model = dict[@"model"];
        _name = dict[@"name"];
        _type = dict[@"type"];
        _token = dict[@"token"];
        _advertisingId = dict[@"advertisingId"];
        _adTrackingEnabled = dict[@"adTrackingEnabled"];
        _attTrackingStatus = [dict[@"attTrackingStatus"] intValue];
    }
    return self;
}

- (NSString*) getDeviceModel {
    NSString* platformString = [self getPlatformString];
    if(platformString != nil) {
        return platformString;
    }
#if !TARGET_OS_WATCH
    return [[UIDevice currentDevice] model];
#else
    return [[WKInterfaceDevice currentDevice]model];
#endif
    
}

- (NSString *) getPlatformString {
    const char *sysctl_name = "hw.model";
#if TARGET_OS_IOS
    BOOL isiOSAppOnMac = NO;
    if (@available(iOS 14.0, *)) {
        isiOSAppOnMac = [NSProcessInfo processInfo].isiOSAppOnMac;
    }
    if (!isiOSAppOnMac){
        sysctl_name = "hw.machine";
    }
#elif TARGET_OS_TV || TARGET_OS_WATCH
    sysctl_name = "hw.machine";
#endif
    size_t size;
    sysctlbyname(sysctl_name, NULL, &size, NULL, 0);
    char *machine = calloc(1, size);
    sysctlbyname(sysctl_name, machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict;
    @synchronized (tempDict){
        tempDict = [[NSMutableDictionary alloc] init];

        [tempDict setValue:_identifier forKey:@"id"];
        [tempDict setValue:_manufacturer forKey:@"manufacturer"];
        [tempDict setValue:_model forKey:@"model"];
        [tempDict setValue:_name forKey:@"name"];
        [tempDict setValue:_type forKey:@"type"];
        if (_token != nil) {
            [tempDict setValue:_token forKey:@"token"];
        }
        if (_advertisingId != nil) {
            [tempDict setValue:_advertisingId forKey:@"advertisingId"];
            [tempDict setValue:[NSNumber numberWithBool:_adTrackingEnabled] forKey:@"adTrackingEnabled"];
        }
        [tempDict setValue:[[NSNumber alloc] initWithInt:_attTrackingStatus] forKey:@"attTrackingStatus"];
        return [tempDict copy];
    }
}

@end
