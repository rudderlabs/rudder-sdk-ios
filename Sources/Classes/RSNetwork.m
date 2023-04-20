//
//  RSNetwork.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSNetwork.h"
#import "RSLogger.h"
#if !TARGET_OS_TV && !TARGET_OS_WATCH
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#endif

@implementation RSNetwork

- (instancetype)init
{
    self = [super init];
    if (self) {
        _carriers = [[NSMutableArray alloc] init];
#if !TARGET_OS_TV && !TARGET_OS_WATCH
        CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
        NSString *carrierName = nil;
        
        if (@available(iOS 12.0, *)) {
            NSDictionary *serviceProviders = [networkInfo serviceSubscriberCellularProviders];
            for (NSString *rat in serviceProviders) {
                CTCarrier *carrier = [serviceProviders objectForKey:rat];
                if (carrier && [carrier carrierName]) {
                    [_carriers addObject:[carrier carrierName]];
                }
            }
        } else {
            CTCarrier *carrier = [networkInfo subscriberCellularProvider];
            carrierName = [carrier carrierName];
            if (carrierName) {
                [_carriers addObject:carrierName];
            }
        }
        
        if(_carriers.count == 0) {
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
        _carriers = dict[@"carrier"];
        _wifi = dict[@"wifi"];
        _cellular = dict[@"cellular"];
    }
    return self;
}

- (NSDictionary<NSString *,NSObject *> *)dict {
    NSMutableDictionary *tempDict;
    @synchronized (tempDict) {
        tempDict = [[NSMutableDictionary alloc] init];
        [tempDict setValue:_carriers forKey:@"carriers"];
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
