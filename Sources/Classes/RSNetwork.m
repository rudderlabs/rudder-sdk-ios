//
//  RSNetwork.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSNetwork.h"
#import "RSLogger.h"
#import "RSUtils.h"
#if !TARGET_OS_TV && !TARGET_OS_WATCH
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#endif

@implementation RSNetwork

- (instancetype)init
{
    self = [super init];
    if (self) {
        _carrier = [[NSMutableArray alloc] init];
#if !TARGET_OS_TV && !TARGET_OS_WATCH
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        if(@available(iOS 16.0, *)) {
            [RSLogger logWarn:@"RSNetwork: init: cannot retrieve carrier names on iOS 16 and above as CTCarrier is deprecated"];
        } else {
            NSDictionary *serviceProviders = [networkInfo serviceSubscriberCellularProviders];
            for (NSString *rat in serviceProviders) {
                CTCarrier *carrier = [serviceProviders objectForKey:rat];
                if(carrier == nil) {
                    continue;
                }
                NSString *carrierName = [carrier carrierName];
                if (carrierName && ![carrierName isEqualToString:@"--"]) {
                    [_carrier addObject:carrierName];
                }
            }
        }
        
        if(_carrier.count == 0) {
            [RSLogger logWarn:@"RSNetwork: init: unable to retrieve carrier name"];
        }
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

- (instancetype) initWithDict:(NSDictionary*) dict {
    self = [super init];
    if(self) {
        _carrier = [[RSUtils getArrayFromCSVString:dict[@"carrier"]] mutableCopy];
        _wifi = [dict[@"wifi"] boolValue];
        _cellular = [dict[@"cellular"] boolValue];
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict;
    @synchronized (tempDict) {
        tempDict = [[NSMutableDictionary alloc] init];
        if(_carrier.count !=0) {
            [tempDict setValue:[RSUtils getCSVString:_carrier] forKey:@"carrier"];
        }
#if !TARGET_OS_WATCH
            [tempDict setValue:[NSNumber numberWithBool:_wifi] forKey:@"wifi"];
            [tempDict setValue:[NSNumber numberWithBool:_cellular] forKey:@"cellular"];
#endif
        return [tempDict copy];
    }
}
@end
