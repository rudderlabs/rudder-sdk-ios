//
//  RSNetwork.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSNetwork.h"

#if !TARGET_OS_TV && !TARGET_OS_WATCH
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#endif

@implementation RSNetwork

- (instancetype)init
{
    self = [super init];
    if (self) {
#if !TARGET_OS_TV && !TARGET_OS_WATCH
        NSString *carrierName = [[[[CTTelephonyNetworkInfo alloc] init] subscriberCellularProvider]carrierName];
        if (carrierName == nil) {
            carrierName = @"unavailable";
        }
        _carrier = carrierName;
#endif
#if !TARGET_OS_WATCH
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, "8.8.8.8");
        SCNetworkReachabilityFlags flags;
        SCNetworkReachabilityGetFlags(reachability, &flags);
        CFRelease(reachability);
        BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
        BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
        _isNetworkReachable = (isReachable && !needsConnection);
        if (_isNetworkReachable) {
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
                _cellular = YES;
            } else {
                _wifi = YES;
            }
        }
#endif
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict;
    @synchronized (tempDict) {
        tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setValue:_carrier forKey:@"carrier"];
#if !TARGET_OS_WATCH
        if(_isNetworkReachable) {
            [tempDict setValue:[NSNumber numberWithBool:_wifi] forKey:@"wifi"];
            [tempDict setValue:[NSNumber numberWithBool:_cellular] forKey:@"cellular"];
        }
#endif
        return [tempDict copy];
    }
}
@end
