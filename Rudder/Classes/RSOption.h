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

@property (nonatomic, strong) NSMutableArray<NSMutableDictionary<NSString*, NSObject*>*>* externalIds;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSObject*>* integrations;

- (instancetype) putExternalId: (NSString*) type withId: (NSString*) idValue;
- (instancetype) putIntegration: (NSString*) type isEnabled: (BOOL) enabled;
//- (instancetype) putIntegrationWithFactory: (id<RSIntegrationFactory>) factory isEnabled: (BOOL) enabled;

@end

NS_ASSUME_NONNULL_END
