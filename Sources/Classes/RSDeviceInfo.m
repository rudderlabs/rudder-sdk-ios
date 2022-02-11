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
#if TARGET_OS_WATCH
#import <WatchKit/WKInterfaceDevice.h>
#endif


@implementation RSDeviceInfo

- (instancetype)init
{
    self = [super init];

    if (self) {
#if !TARGET_OS_WATCH
        _identifier = [[[[UIDevice currentDevice] identifierForVendor] UUIDString]lowercaseString];
        _model = [[UIDevice currentDevice] model];
        _name = [[UIDevice currentDevice] name];
        _type = [[UIDevice currentDevice] systemName];
#else
        _identifier = [[[[WKInterfaceDevice currentDevice] identifierForVendor]UUIDString] lowercaseString];
        _model = [[WKInterfaceDevice currentDevice]model];
        _name = [[WKInterfaceDevice currentDevice]name];
        _type = [[WKInterfaceDevice currentDevice]systemName];
#endif
        _manufacturer = @"Apple";
        _attTrackingStatus = RSATTNotDetermined;
    }

    return self;
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
            [tempDict setValue:[[NSNumber alloc] initWithInt:_attTrackingStatus] forKey:@"attTrackingStatus"];
        }
        return [tempDict copy];
    }
}

@end
