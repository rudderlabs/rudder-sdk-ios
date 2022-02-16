//
//  RSOption.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSOption.h"
#import "RSConfig.h"
#import "RSContext.h"

@implementation RSOption

- (instancetype)init
{
    self = [super init];
    if (self) {
        _externalIds = nil;
        _customContexts = nil;
        _integrations = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (instancetype)putExternalId:(NSString *)type withId:(NSString *)idValue {
    if (_externalIds == nil) {
        _externalIds = [[NSMutableArray alloc] init];
    }
    
    dispatch_sync([RSContext getQueue], ^{
        // find out if something is already present in the storage (PreferenceManager)
        NSMutableDictionary* externalIdDict = nil;
        int dictIndex = -1;
        for (int index = 0; index < _externalIds.count; index += 1) {
            NSMutableDictionary* dict = _externalIds[index];
            NSString* dictType = dict[@"type"];
            if (dictType != nil && [dictType isEqual:type]) {
                externalIdDict = dict;
                dictIndex = index;
                break;
            }
        }
    
        // if not present from previous runs: create new and assign the type
        if (externalIdDict == nil) {
            externalIdDict = [[NSMutableDictionary alloc] initWithDictionary:@{
                @"type": type
            }];
        }
        
        // assign new id or update existing id
        [externalIdDict setValue:idValue forKey:@"id"];
        
        // finally update existing position or add new id
        if (dictIndex == -1) {
            [_externalIds addObject:externalIdDict];
        } else {
            _externalIds[dictIndex][@"id"] = idValue;
        }
    });
    // return for builder pattern
    return self;
}

- (instancetype) putIntegration: (NSString*) type isEnabled: (BOOL) enabled {
    [_integrations setValue:[NSNumber numberWithBool:enabled] forKey:type];
    return self;
}

- (instancetype) putIntegrationWithFactory:(id<RSIntegrationFactory>)factory isEnabled:(BOOL)enabled {
    [_integrations setValue:[NSNumber numberWithBool:enabled] forKey: factory.key];
    return self;
}

- (instancetype) putCustomContext:(NSDictionary<NSString*, id>*) context withKey:(NSString *) key {
    if (_customContexts == nil) {
        _customContexts = [[NSMutableDictionary alloc] init];
    }
    if(key != nil && context != nil)
    {
        [_customContexts setValue:context forKey:key];
    }
    return self;
}


@end
