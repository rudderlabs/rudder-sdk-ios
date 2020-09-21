//
//  RSOption.m
//  RSSDKCore
//
//  Created by Arnab Pal on 17/10/19.
//  Copyright © 2019 RSlabs. All rights reserved.
//

#import "RSOption.h"

@implementation RSOption

- (instancetype)init
{
    self = [super init];
    if (self) {
        _externalIds = nil;
    }
    return self;
}

- (instancetype)putExternalId:(NSString *)type withId:(NSString *)idValue {
    if (_externalIds == nil) {
        _externalIds = [[NSMutableArray alloc] init];
    }
    
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
    
    // return for builder pattern
    return self;
}

@end
