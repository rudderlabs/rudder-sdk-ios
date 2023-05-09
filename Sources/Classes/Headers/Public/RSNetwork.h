//
//  RSNetwork.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#if !TARGET_OS_WATCH
#import <SystemConfiguration/SCNetworkReachability.h>
#endif
NS_ASSUME_NONNULL_BEGIN

@interface RSNetwork : NSObject
- (instancetype)initWithDict:(NSDictionary *)dict;
- (NSDictionary<NSString *, NSObject *> *)dict;

@property(nonatomic, strong) NSMutableArray<NSString *> *carrier;
@property(nonatomic, readwrite) bool wifi;
@property(nonatomic, readwrite) bool isNetworkReachable;
@property(nonatomic, readwrite) bool cellular;

@end

NS_ASSUME_NONNULL_END
