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

- (NSString *) getDeviceModel {
    NSString *platform = [self getPlatformString];
    // == iPhone ==
    // iPhone 1
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1";
    // iPhone 3
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    // iPhone 4
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    // iPhone 5
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    // iPhone 6
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    // iPhone 7
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    // iPhone 8
    if ([platform isEqualToString:@"iPhone10,1"])    return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"])    return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus";
    // iPhone X
    if ([platform isEqualToString:@"iPhone10,3"])    return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"])    return @"iPhone X";
    // iPhone XS
    if ([platform isEqualToString:@"iPhone11,2"])    return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,6"])    return @"iPhone XS Max";
    // iPhone XR
    if ([platform isEqualToString:@"iPhone11,8"])    return @"iPhone XR";
    // iPhone 11
    if ([platform isEqualToString:@"iPhone12,1"])    return @"iPhone 11";
    if ([platform isEqualToString:@"iPhone12,3"])    return @"iPhone 11 Pro";
    if ([platform isEqualToString:@"iPhone12,5"])    return @"iPhone 11 Pro Max";
    // iPhone 12
    if ([platform isEqualToString:@"iPhone13,1"])    return @"iPhone 12 Mini";
    if ([platform isEqualToString:@"iPhone13,2"])    return @"iPhone 12";
    if ([platform isEqualToString:@"iPhone13,3"])    return @"iPhone 12 Pro";
    if ([platform isEqualToString:@"iPhone13,4"])    return @"iPhone 12 Pro Max";
    // iPhone 13
    if ([platform isEqualToString:@"iPhone14,4"])    return @"iPhone 13 Mini";
    if ([platform isEqualToString:@"iPhone14,5"])    return @"iPhone 13";
    if ([platform isEqualToString:@"iPhone14,2"])    return @"iPhone 13 Pro";
    if ([platform isEqualToString:@"iPhone14,3"])    return @"iPhone 13 Pro Max";
    // iPhone 14
    if ([platform isEqualToString:@"iPhone14,7"])    return @"iPhone 14";
    if ([platform isEqualToString:@"iPhone14,8"])    return @"iPhone 14 Plus";
    if ([platform isEqualToString:@"iPhone15,2"])    return @"iPhone 14 Pro";
    if ([platform isEqualToString:@"iPhone15,3"])    return @"iPhone 14 Pro Max";
    // iPhone 15
    if ([platform isEqualToString:@"iPhone15,4"])    return @"iPhone 15";
    if ([platform isEqualToString:@"iPhone15,5"])    return @"iPhone 15 Plus";
    if ([platform isEqualToString:@"iPhone16,1"])    return @"iPhone 15 Pro";
    if ([platform isEqualToString:@"iPhone16,2"])    return @"iPhone 15 Pro Max";
    // iPhone SE
    if ([platform isEqualToString:@"iPhone8,4"])     return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone12,8"])    return @"iPhone SE 2";
    if ([platform isEqualToString:@"iPhone14,6"])    return @"iPhone SE 3";
    
    
    
    // == iPod ==
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    if ([platform isEqualToString:@"iPod9,1"])      return @"iPod Touch 7G";
    
    // == iPad ==
    // iPad 1
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1";
    // iPad 2
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    // iPad 3
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3";
    // iPad 4
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4";
    // iPad 5
    if ([platform isEqualToString:@"iPad6,11"])      return @"iPad 5";
    if ([platform isEqualToString:@"iPad6,12"])      return @"iPad 5";
    // iPad 6
    if ([platform isEqualToString:@"iPad7,5"])      return @"iPad 6";
    if ([platform isEqualToString:@"iPad7,6"])      return @"iPad 6";
    // iPad 7
    if ([platform isEqualToString:@"iPad7,11"])      return @"iPad 7";
    if ([platform isEqualToString:@"iPad7,12"])      return @"iPad 7";
    // iPad 8
    if ([platform isEqualToString:@"iPad11,6"])      return @"iPad 8";
    if ([platform isEqualToString:@"iPad11,7"])      return @"iPad 8";
    // iPad 9
    if ([platform isEqualToString:@"iPad12,1"])      return @"iPad 9";
    if ([platform isEqualToString:@"iPad12,2"])      return @"iPad 9";
    // iPad 10
    if ([platform isEqualToString:@"iPad13,18"])      return @"iPad 10";
    if ([platform isEqualToString:@"iPad13,19"])      return @"iPad 10";
    
    
    // iPad Air
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    // iPad Air 2
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    // iPad Air 3
    if ([platform isEqualToString:@"iPad11,3"])      return @"iPad Air 3";
    if ([platform isEqualToString:@"iPad11,4"])      return @"iPad Air 3";
    // iPad Air 4
    if ([platform isEqualToString:@"iPad13,1"])      return @"iPad Air 4";
    if ([platform isEqualToString:@"iPad13,2"])      return @"iPad Air 4";
    // iPad Air 5
    if ([platform isEqualToString:@"iPad13,16"])      return @"iPad Air 5";
    if ([platform isEqualToString:@"iPad13,17"])      return @"iPad Air 5";
    
    
    // iPad Pro
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad6,3"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad6,4"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad7,1"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad7,2"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad7,3"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad7,4"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,1"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,2"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,3"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,4"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,5"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,6"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,7"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,8"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,9"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,10"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,11"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad8,12"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad13,4"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad13,5"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad13,6"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad13,7"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad13,8"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad13,9"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad13,10"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad13,11"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad14,3"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad14,4"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad14,5"])      return @"iPad Pro";
    if ([platform isEqualToString:@"iPad14,6"])      return @"iPad Pro";
    
    
    
    
    // iPad Mini
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini";
    // iPad Mini 2
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    // iPad Mini 3
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    // iPad Mini 4
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad Mini 4";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad Mini 4";
    // iPad Mini 5
    if ([platform isEqualToString:@"iPad11,1"])      return @"iPad Mini 5";
    if ([platform isEqualToString:@"iPad11,2"])      return @"iPad Mini 5";
    // iPad Mini 6
    if ([platform isEqualToString:@"iPad14,1"])      return @"iPad Mini 6";
    if ([platform isEqualToString:@"iPad14,2"])      return @"iPad Mini 6";
    
    // == Apple Watch ==
    if ([platform isEqualToString:@"Watch1,1"])     return @"Apple Watch 38mm";
    if ([platform isEqualToString:@"Watch1,2"])     return @"Apple Watch 42mm";
    if ([platform isEqualToString:@"Watch2,6"])     return @"Apple Watch Series 1 38mm";
    if ([platform isEqualToString:@"Watch2,7"])     return @"Apple Watch Series 1 42mm";
    if ([platform isEqualToString:@"Watch2,3"])     return @"Apple Watch Series 2 38mm";
    if ([platform isEqualToString:@"Watch2,4"])     return @"Apple Watch Series 2 42mm";
    if ([platform isEqualToString:@"Watch3,1"])     return @"Apple Watch Series 3 38mm Cellular";
    if ([platform isEqualToString:@"Watch3,2"])     return @"Apple Watch Series 3 42mm Cellular";
    if ([platform isEqualToString:@"Watch3,3"])     return @"Apple Watch Series 3 38mm";
    if ([platform isEqualToString:@"Watch3,4"])     return @"Apple Watch Series 3 42mm";
    if ([platform isEqualToString:@"Watch4,1"])     return @"Apple Watch Series 4 40mm";
    if ([platform isEqualToString:@"Watch4,2"])     return @"Apple Watch Series 4 44mm";
    if ([platform isEqualToString:@"Watch4,3"])     return @"Apple Watch Series 4 40mm Cellular";
    if ([platform isEqualToString:@"Watch4,4"])     return @"Apple Watch Series 4 44mm Cellular";
    if ([platform isEqualToString:@"Watch5,1"])     return @"Apple Watch Series 5 40mm";
    if ([platform isEqualToString:@"Watch5,2"])     return @"Apple Watch Series 5 44mm";
    if ([platform isEqualToString:@"Watch5,3"])     return @"Apple Watch Series 5 40mm Cellular";
    if ([platform isEqualToString:@"Watch5,4"])     return @"Apple Watch Series 5 44mm Cellular";
    if ([platform isEqualToString:@"Watch6,1"])     return @"Apple Watch Series 6 40mm";
    if ([platform isEqualToString:@"Watch6,2"])     return @"Apple Watch Series 6 44mm";
    if ([platform isEqualToString:@"Watch6,3"])     return @"Apple Watch Series 6 40mm Cellular";
    if ([platform isEqualToString:@"Watch6,4"])     return @"Apple Watch Series 6 44mm Cellular";
    if ([platform isEqualToString:@"Watch6,6"])     return @"Apple Watch Series 7 41mm";
    if ([platform isEqualToString:@"Watch6,7"])     return @"Apple Watch Series 7 45mm";
    if ([platform isEqualToString:@"Watch6,8"])     return @"Apple Watch Series 7 41mm Cellular";
    if ([platform isEqualToString:@"Watch6,9"])     return @"Apple Watch Series 7 45mm Cellular";
    if ([platform isEqualToString:@"Watch6,14"])     return @"Apple Watch Series 8 41mm";
    if ([platform isEqualToString:@"Watch6,15"])     return @"Apple Watch Series 8 45mm";
    if ([platform isEqualToString:@"Watch6,16"])     return @"Apple Watch Series 8 41mm Cellular";
    if ([platform isEqualToString:@"Watch6,17"])     return @"Apple Watch Series 8 45mm Cellular";
    if ([platform isEqualToString:@"Watch7,1"])     return @"Apple Watch Series 9 41mm";
    if ([platform isEqualToString:@"Watch7,2"])     return @"Apple Watch Series 9 45mm";
    if ([platform isEqualToString:@"Watch7,3"])     return @"Apple Watch Series 9 41mm Cellular";
    if ([platform isEqualToString:@"Watch7,4"])     return @"Apple Watch Series 9 45mm Cellular";
    
    if ([platform isEqualToString:@"Watch6,18"])     return @"Apple Watch Ultra";
    if ([platform isEqualToString:@"Watch7,5"])      return @"Apple Watch Ultra 2";
    
    
    if ([platform isEqualToString:@"Watch5,9"])      return @"Apple Watch SE 40mm ";
    if ([platform isEqualToString:@"Watch5,10"])     return @"Apple Watch SE 44mm";
    if ([platform isEqualToString:@"Watch5,11"])     return @"Apple Watch SE 40mm Cellular";
    if ([platform isEqualToString:@"Watch5,12"])     return @"Apple Watch SE 44mm Cellular";
    
    if ([platform isEqualToString:@"Watch6,10"])     return @"Apple Watch SE 2 40mm ";
    if ([platform isEqualToString:@"Watch6,11"])     return @"Apple Watch SE 2 44mm";
    if ([platform isEqualToString:@"Watch6,12"])     return @"Apple Watch SE 2 40mm Cellular";
    if ([platform isEqualToString:@"Watch6,13"])     return @"Apple Watch SE 2 44mm Cellular";
    
    // == Others ==
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    if ([platform isEqualToString:@"arm64"])        return @"Simulator";
    if ([platform hasPrefix:@"MacBookAir"])         return @"MacBook Air";
    if ([platform hasPrefix:@"MacBookPro"])         return @"MacBook Pro";
    if ([platform hasPrefix:@"MacBook"])            return @"MacBook";
    if ([platform hasPrefix:@"MacPro"])             return @"Mac Pro";
    if ([platform hasPrefix:@"Macmini"])            return @"Mac Mini";
    if ([platform hasPrefix:@"iMac"])               return @"iMac";
    if ([platform hasPrefix:@"Xserve"])             return @"Xserve";
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
