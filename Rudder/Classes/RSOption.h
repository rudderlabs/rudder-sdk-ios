//
//  RSOption.h
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RSOption : NSObject

- (instancetype) init;

+ (NSMutableDictionary *) integrations;
+ (NSMutableDictionary *) context;


+ (RSOption *) setIntegration:(NSString *) integrationKey enabled: (BOOL) enabled;
+ (RSOption *) setIntegrationOptions: (NSString *) integrationKey options : (NSDictionary *) options;
+ (RSOption *) putContext: (NSString *) key value: (NSObject *) value;

@end

NS_ASSUME_NONNULL_END
